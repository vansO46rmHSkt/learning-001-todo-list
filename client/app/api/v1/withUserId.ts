import { getServerSession } from "next-auth/next";
import authOptions from "../auth/[...nextauth]/authOptions";

const getUserId = async (): Promise<string | undefined> => {
  const session = await getServerSession(authOptions);
  return session?.user?.id;
};

export const withUserId = async (
  callback: (userId: string) => Promise<Response>,
) => {
  const userId = await getUserId();
  if (userId === undefined) {
    return Response.json("Unauthorized", { status: 401 });
  }
  return callback(userId);
};

export default withUserId;
