"use client";

import { Task } from "@/types/tasks";
import { FormEventHandler, useCallback, useReducer } from "react";
import { MdClose } from "react-icons/md";

const actions: Record<string, (previous: Task[], user: Task) => Task[]> = {
  add: (previous, task) =>
    [task, ...previous].sort((a, b) => a.order - b.order),
  remove: (previous, task) =>
    previous.filter((t) => t.id !== task.id).sort((a, b) => a.order - b.order),
} as const;

const TodoList = (props: { tasks: Task[] }) => {
  const [tasks, action] = useReducer(
    (
      previous: Task[],
      { type, task }: { type: keyof typeof actions; task: Task },
    ) => actions[type](previous, task),
    [...props.tasks],
  );

  const handleOnSubmit: FormEventHandler<HTMLFormElement> = useCallback(
    async (e) => {
      e.preventDefault();
      const title = (e.target as any).title.value as string;
      if (title) {
        const response = await fetch("http://localhost:3000/api/v1/tasks", {
          method: "POST",
          body: JSON.stringify({
            task: { order: tasks.length + 1, title },
          }),
        });
        const task = await response.json();
        if (response.status === 201) {
          action({ type: "add", task });
        }
      }
    },
    [tasks.length],
  );

  const handleOnRemove = useCallback(
    (task: Task) => async () => {
      const status = await fetch(
        `http://localhost:3000/api/v1/tasks/${task.id}`,
        {
          method: "DELETE",
        },
      ).then((res) => res.status);
      if (status === 204) {
        action({ type: "remove", task });
      }
    },
    [],
  );

  const handleOnClose = useCallback(
    (task: Task) => async () => {
      const status = await fetch(
        `http://localhost:3000/api/v1/tasks/${task.id}`,
        {
          method: "PUT",
          body: JSON.stringify({
            status: "closed",
          }),
        },
      ).then((res) => res.status);
      if (status === 200) {
        action({ type: "remove", task });
      }
    },
    [],
  );

  return (
    <div className="relative flex flex-col items-center py-8">
      <form
        className="flex w-1/3 flex-col space-y-4 rounded-md p-8"
        onSubmit={handleOnSubmit}
      >
        <label className="space-y-1">
          <span className="text-sm">タイトル</span>
          <input
            name="title"
            className="w-full rounded-md border px-4 py-3 text-base outline-none focus:ring-2"
          />
        </label>
        <button
          type="submit"
          className="ml-auto h-12 w-32 cursor-pointer rounded-lg border p-4 py-0 outline-none focus:ring-2"
        >
          作成
        </button>
      </form>
      {tasks.map((task) => (
        <div key={task.id} className="flex w-full justify-center">
          <div className="w-1/3 bg-white p-8">
            <div className="group flex justify-between">
              <div className="flex items-center">
                <button
                  className="h-5 w-5 rounded-xl border"
                  onClick={handleOnClose(task)}
                />
                <div
                  role="heading"
                  aria-level={4}
                  className="pl-4 text-xl font-bold"
                >
                  {`${task.title}`}
                </div>
              </div>
              <button
                title="削除"
                aria-label="削除"
                className="invisible group-hover:visible"
                onClick={handleOnRemove(task)}
              >
                <MdClose />
              </button>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
};

export default TodoList;
