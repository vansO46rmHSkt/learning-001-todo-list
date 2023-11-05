import { Task } from "@/types/tasks";
import TodoList from "./TodoList";
import { sleep } from "@/lib/misc";

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

const TodoListPage = async () => {
  const tasks = await sleep(1000).then(() => [...TASKS]);

  return <TodoList tasks={tasks} />;
};

export default TodoListPage;
