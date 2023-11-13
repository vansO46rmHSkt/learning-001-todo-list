"use client";

import { TaskBase } from "@/types/tasks";
import { FormEventHandler, useCallback } from "react";
import { MdClose } from "react-icons/md";
import useTasks from "./useTask";

const TodoListPage = () => {
  const { tasks, isError, isLoading, actions } = useTasks();
  const handleOnSubmit: FormEventHandler<HTMLFormElement> = useCallback(
    (e) => {
      e.preventDefault();
      const title = (e.target as any).title.value as string;
      actions.createTask(title);
    },
    [actions],
  );

  const handleOnRemove = useCallback(
    (task: TaskBase) => () => {
      actions.removeTask(task);
    },
    [actions],
  );

  const handleOnClose = useCallback(
    (task: TaskBase) => () => {
      actions.closeTask(task);
    },
    [actions],
  );

  if (isError) return <div>failed to load</div>;
  if (isLoading) return <div>loading...</div>;

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

export default TodoListPage;
