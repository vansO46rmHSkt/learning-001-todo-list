import { Task } from "@/types/tasks";
import { headers } from "next/headers";
import TodoList from "./TodoList";

const TodoListPage = async () => {
  const tasks = (await fetch(
    `http://${headers().get("host")}/api/v1/tasks`,
  ).then((data) => data.json())) as Task[];
  return <TodoList tasks={tasks} />;
};

export default TodoListPage;
