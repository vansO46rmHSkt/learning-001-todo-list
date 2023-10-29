import { Task } from "@/types/tasks";

const TASKS = [
  {
    id: "1",
    title: "title-1",
  },
  {
    id: "2",
    title: "title-2",
  },
  {
    id: "3",
    title: "title-3",
  },
] as const satisfies readonly Task[];

export const GET = () => {
  return Response.json(TASKS);
};
