import {
  DynamoDBClient,
  QueryCommand,
  QueryCommandInput,
  QueryCommandOutput,
} from "@aws-sdk/client-dynamodb";

if (typeof window !== "undefined") {
  throw new Error("This file must be imported in server side");
}

export const client = new DynamoDBClient({});

export const paginationByQuery = async (
  input: QueryCommandInput,
  acc: NonNullable<QueryCommandOutput["Items"]> = [],
) => {
  const { Items, LastEvaluatedKey } = await client.send(
    new QueryCommand(input),
  );
  Items?.forEach((i) => acc.push(i));
  if (!LastEvaluatedKey) {
    return acc;
  }
  paginationByQuery({ ...input, ExclusiveStartKey: LastEvaluatedKey }, acc);
};
