import { DynamoDBStreamEvent, Handler } from "aws-lambda";
import { Client } from "@opensearch-project/opensearch";
import { AwsSigv4Signer } from "@opensearch-project/opensearch/aws";
import { defaultProvider } from "@aws-sdk/credential-provider-node";
import { unmarshall } from "@aws-sdk/util-dynamodb";

const INDEX_NAME = "tasks" as const;

const client = new Client({
  ...AwsSigv4Signer({
    region: process.env.AWS_REGION,
    service: "aoss",
    getCredentials: defaultProvider(),
  }),
  node: process.env.AWS_OPENSEARCH_ENDPOINT,
});

export const handler: Handler = async (event: DynamoDBStreamEvent) => {
  for (const record of event.Records) {
    if (
      !record.eventName ||
      !record.dynamodb?.Keys?.["partitionKey"]?.S ||
      !record.dynamodb?.Keys?.["sortKey"]?.S
    ) {
      continue;
    }

    const { partitionKey, sortKey } = record.dynamodb.Keys;
    const id = `${partitionKey.S}#${sortKey.S}`;
    switch (record.eventName) {
      case "INSERT":
      case "MODIFY": {
        if (!record.dynamodb.NewImage) {
          continue;
        }
        console.log(`Updating ${id}`);
        // create index if it doesn't already exist
        if (!(await client.indices.exists({ index: INDEX_NAME })).body) {
          console.log(
            (await client.indices.create({ index: INDEX_NAME })).body,
          );
        }

        const document = unmarshall(
          record.dynamodb.NewImage as Parameters<typeof unmarshall>[0],
        );
        const response = await client.index({
          id,
          index: INDEX_NAME,
          body: document,
        });
        console.log(response.body);
        break;
      }
      case "REMOVE": {
        console.log(`Removing ${id}`);
        console.log((await client.delete({ index: INDEX_NAME, id })).body);
        break;
      }
    }
  }
};
