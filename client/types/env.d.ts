declare module "process" {
  global {
    namespace NodeJS {
      interface ProcessEnv {
        NEXTAUTH_COGNITO_CLIENT_ID: string;
        NEXTAUTH_COGNITO_CLIENT_SECRET: string;
        NEXTAUTH_COGNITO_ISSUER: string;
      }
    }
  }
}
