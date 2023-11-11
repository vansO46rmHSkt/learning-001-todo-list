import { client } from "@/lib/dynamodb";
import {
  DeleteItemCommand
} from "@aws-sdk/client-dynamodb";

const TableName = "Task" as const;

export const DELETE = async (
  _: Request,
  { params }: { params: { id: string } },
) => {
  const userId = "test01";
  // const requestBody = await request.json();
  // const userId = requestBody["userId"];
  await client.send(
    new DeleteItemCommand({
      TableName,
      Key: {
        UserId: {
          S: userId,
        },
        TaskId: {
          S: params.id,
        },
      },
    }),
  );
  return Response.json({ status: 204 });
};
