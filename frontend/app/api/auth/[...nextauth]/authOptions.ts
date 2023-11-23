import { AuthOptions } from "next-auth";
import CognitoProvider from "next-auth/providers/cognito";

const authOptions: AuthOptions = {
  providers: [
    CognitoProvider({
      clientId: process.env.NEXTAUTH_COGNITO_CLIENT_ID,
      clientSecret: process.env.NEXTAUTH_COGNITO_CLIENT_SECRET,
      issuer: process.env.NEXTAUTH_COGNITO_ISSUER,
    }),
  ],
  callbacks: {
    session: async ({ session, token }) => {
      if (session.user) {
        session.user.id = token.sub;
      }
      return session;
    },
  },
};

export default authOptions;
