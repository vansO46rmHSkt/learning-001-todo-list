export { default } from "next-auth/middleware";

export const config = {
  matcher: ["/((?!api/v1/health).*)"],
};
