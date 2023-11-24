declare module "process" {
  global {
    namespace NodeJS {
      interface ProcessEnv {
        AWS_REGION: string;
        AWS_OPENSEARCH_ENDPOINT: string;
      }
    }
  }
}
