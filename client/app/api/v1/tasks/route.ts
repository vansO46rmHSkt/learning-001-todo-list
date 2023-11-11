import { client, paginationByQuery } from "@/lib/dynamodb";
import {
  DraftTask,
  TaskItem,
  draftToTask,
  convertToItem,
  convertFromItem,
} from "@/types/tasks";
import { PutItemCommand } from "@aws-sdk/client-dynamodb";

const TableName = "Task" as const;

export const GET = async (request: Request) => {
  const userId = "test01";
  // const userId = (await request.json())["userId"];
  const data = await paginationByQuery({
    TableName,
    IndexName: "ParentIndex",
    KeyConditionExpression: "UserId = :u AND begins_with(Parent_Order, :p)",
    ExpressionAttributeValues: { ":u": { S: userId }, ":p": { S: "Root#" } },
  });

  return Response.json(
    data?.map((i) => convertFromItem(i as Required<TaskItem>)),
    {
      status: 200,
    },
  );
};

export const POST = async (request: Request) => {
  const requestBody = await request.json();
  const userId = "test01";
  // const userId = requestBody["userId"];
  const draft = requestBody["task"] as DraftTask;

  const task = draftToTask(draft);
  await client.send(
    new PutItemCommand({
      TableName,
      Item: convertToItem(userId, task, true),
    }),
  );
  return Response.json(task, { status: 201 });
};
