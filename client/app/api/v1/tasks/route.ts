import { TABLE_NAME, client, paginationByQuery } from "@/shared/dynamodb";
import { DraftTask, SPLITTER, ROOT_TASK_PREFIX } from "@/types/tasks";
import { TaskItem, openTask, convertToItem, convertFromItem } from "./actions";
import { PutItemCommand } from "@aws-sdk/client-dynamodb";
import { NextRequest } from "next/server";

export const GET = async (request: NextRequest) => {
  const userId = "test01";
  const status = request.nextUrl.searchParams.get("status");
  const data = await paginationByQuery({
    TableName: TABLE_NAME,
    IndexName: "GSI1",
    KeyConditionExpression:
      "PK_GSI1PK_GSI3PK = :u AND begins_with(GSI1SK_GSI2SK, :p)",
    ExpressionAttributeValues: {
      ":u": { S: userId },
      ":p": {
        S: `Task${SPLITTER}${status}${SPLITTER}${ROOT_TASK_PREFIX}${SPLITTER}`,
      },
    },
  });

  return Response.json(
    data?.map((i) => convertFromItem(i as Required<TaskItem>)),
    {
      status: 200,
    },
  );
};

export const POST = async (request: Request) => {
  const userId = "test01";
  const draft = (await request.json()) as DraftTask;

  const task = openTask(draft);
  await client.send(
    new PutItemCommand({
      TableName: TABLE_NAME,
      Item: convertToItem(userId, task, true),
    }),
  );
  return Response.json(task, { status: 201 });
};
