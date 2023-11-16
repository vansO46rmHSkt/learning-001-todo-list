import { TABLE_NAME, client } from "@/shared/dynamodb";
import { ClosedTask, OpenTask, SPLITTER } from "@/types/tasks";
import {
  TaskItem,
  closeTask,
  convertFromItem,
  convertToItem,
  filterPrimaryKey,
  mergeTask,
} from "../actions";
import {
  DeleteItemCommand,
  GetItemCommand,
  UpdateItemCommand,
} from "@aws-sdk/client-dynamodb";
import withUserId from "../../withUserId";

const findOneTask = async (userId: string, taskId: string) => {
  const { Item } = await client.send(
    new GetItemCommand({
      TableName: TABLE_NAME,
      Key: {
        PK_GSI1PK_GSI3PK: { S: userId },
        SK: { S: `Task${SPLITTER}${taskId}` },
      },
    }),
  );
  return Item;
};

export const GET = async (
  _: Request,
  { params }: { params: { id: string } },
) => {
  return withUserId(async (userId) => {
    const task = await findOneTask(userId, params.id);
    if (!task) {
      return Response.json(
        "Task not found. Please ensure the Task ID is correct.",
        { status: 404 },
      );
    }
    return Response.json(convertFromItem(task as Required<TaskItem>), {
      status: 200,
    });
  });
};

export const PUT = async (
  request: Request,
  { params }: { params: { id: string } },
) => {
  return withUserId(async (userId) => {
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

    const currentTask = convertFromItem(item as Required<TaskItem>);
    let task: OpenTask | ClosedTask;
    if (currentTask.status === "Open" && requestBody.status === "Closed") {
      task = closeTask(currentTask);
    } else {
      task = mergeTask(currentTask, requestBody);
    }
    task.updatedAt = new Date().toISOString();

    const updatedItem = convertToItem(userId, task);
    await client.send(
      new UpdateItemCommand({
        TableName: TABLE_NAME,
        Key: {
          PK_GSI1PK_GSI3PK: { S: userId },
          SK: { S: `Task${SPLITTER}${params.id}` },
        },
        UpdateExpression: `SET ${Object.keys(updatedItem)
          .filter(filterPrimaryKey)
          .map((k) => `${k} = :${k}`)
          .join(", ")}`,
        ExpressionAttributeValues: Object.entries(updatedItem)
          .filter(([k]) => filterPrimaryKey(k))
          .reduce((acc, [k, v]) => ({ ...acc, [`:${k}`]: v }), {}),
      }),
    );

    return Response.json(task, { status: 200 });
  });
};

export const DELETE = async (
  _: Request,
  { params }: { params: { id: string } },
) => {
  return withUserId(async (userId) => {
    const task = findOneTask(userId, params.id);
    if (task === undefined) {
      return Response.json(
        "Task not found. Please ensure the Task ID is correct.",
        { status: 404 },
      );
    }

    await client.send(
      new DeleteItemCommand({
        TableName: TABLE_NAME,
        Key: {
          PK_GSI1PK_GSI3PK: { S: userId },
          SK: { S: `Task${SPLITTER}${params.id}` },
        },
      }),
    );
    return new Response(null, {
      status: 204,
    });
  });
};
