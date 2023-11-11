import { client } from "@/lib/dynamodb";
import { Task, TaskItem, convertFromItem, convertToItem } from "@/types/tasks";
import {
  DeleteItemCommand,
  QueryCommand,
  UpdateItemCommand,
} from "@aws-sdk/client-dynamodb";

const TableName = "Task" as const;

const findOneTask = async (userId: string, taskId: string) => {
  const { Items } = await client.send(
    new QueryCommand({
      TableName,
      KeyConditionExpression: "#U = :u AND #T = :t",
      ExpressionAttributeNames: { "#U": "UserId", "#T": "TaskId" },
      ExpressionAttributeValues: { ":u": { S: userId }, ":t": { S: taskId } },
    }),
  );
  return Items?.[0];
};

export const GET = async (
  _: Request,
  { params }: { params: { id: string } },
) => {
  const userId = "test01";
  const task = await findOneTask(userId, params.id);
  return Response.json(convertFromItem(task as Required<TaskItem>), {
    status: 200,
  });
};

const mergeTask = (before: Task, after: Task): Task => {
  return ([...Object.keys(after)] as (keyof Task)[]).reduce(
    (acc, key) => {
      if (after[key] != null) {
        acc[key] = after[key] as never;
      }
      return acc;
    },
    {
      ...before,
    } as Task,
  );
};

export const PUT = async (
  request: Request,
  { params }: { params: { id: string } },
) => {
  const userId = "test01";
  const requestBody = await request.json();
  if (!requestBody) {
    return Response.json("Invalid request body.", { status: 400 });
  }

  const item = await findOneTask(userId, params.id);
  if (!item) {
    return Response.json(
      "Task not found. Please ensure the Task ID is correct.",
      { status: 404 },
    );
  }

  const task = mergeTask(
    convertFromItem(item as Required<TaskItem>),
    requestBody as Task,
  );
  task.updatedAt = new Date().toISOString();
  const updatedItem = convertToItem(userId, task);
  await client.send(
    new UpdateItemCommand({
      TableName,
      Key: { UserId: { S: userId }, TaskId: { S: params.id } },
      UpdateExpression:
        "SET #PO = :po, #UT = :ut, #UC = :uc, #US = :us, #D = :d, #UA = :ua",
      ExpressionAttributeNames: {
        "#PO": "Parent_Order",
        "#UT": "UserId_Title",
        "#UC": "UserId_Category",
        "#US": "UserId_Status",
        "#D": "Detail",
        "#UA": "UpdatedAt",
      },
      ExpressionAttributeValues: {
        ":po": updatedItem.Parent_Order,
        ":ut": updatedItem.UserId_Title,
        ":uc": updatedItem.UserId_Category,
        ":us": updatedItem.UserId_Status,
        ":d": updatedItem.Detail,
        ":ua": updatedItem.UpdatedAt,
      },
    }),
  );

  return Response.json(task, { status: 200 });
};

export const DELETE = async (
  _: Request,
  { params }: { params: { id: string } },
) => {
  const userId = "test01";
  const task = findOneTask(userId, params.id);
  if (task === undefined) {
    return Response.json(
      "Task not found. Please ensure the Task ID is correct.",
      { status: 404 },
    );
  }

  await client.send(
    new DeleteItemCommand({
      TableName,
      Key: { UserId: { S: userId }, TaskId: { S: params.id } },
    }),
  );
  return new Response(null, {
    status: 204,
  });
};
