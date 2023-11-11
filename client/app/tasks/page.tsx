import TodoList from "./TodoList";

const fetcher = (url: string) => fetch(url).then((res) => res.json());
const TodoListPage = async () => {
  const tasks = await fetcher("http://localhost:3000/api/v1/tasks?status=normal");
  return <TodoList tasks={tasks} />;
};

export default TodoListPage;
