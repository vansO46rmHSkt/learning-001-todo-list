"use client";

import { TaskBase } from "@/types/tasks";
import { useButton } from "@react-aria/button";
import { FormEventHandler, useCallback, useRef } from "react";
import { MdClose } from "react-icons/md";
import useTasks from "./useTask";

const CreateTaskForm = ({
  onSubmit,
}: {
  onSubmit: FormEventHandler<HTMLFormElement>;
}) => {
  const buttonRef = useRef<HTMLButtonElement>(null);
  const { buttonProps } = useButton({ type: "submit" }, buttonRef);
  return (
    <form
      className="flex w-1/3 flex-col space-y-4 rounded-md p-8"
      onSubmit={onSubmit}
    >
      <label className="space-y-1">
        <span className="text-sm">タイトル</span>
        <input
          name="title"
          className="w-full rounded-md border px-4 py-3 text-base outline-none focus:ring-2"
        />
      </label>
      <button
        {...buttonProps}
        ref={buttonRef}
        className="ml-auto h-12 w-32 cursor-pointer rounded-lg border p-4 py-0 outline-none focus:ring-2"
      >
        作成
      </button>
    </form>
  );
};

const TaskCard = ({
  task,
  onRemove,
  onClose,
}: {
  task: TaskBase;
  onClose: (task: TaskBase) => void;
  onRemove: (task: TaskBase) => void;
}) => {
  const closeButtonRef = useRef<HTMLButtonElement>(null);
  const { buttonProps: closeButtonProps } = useButton(
    { onPress: () => onClose(task) },
    closeButtonRef,
  );
  const removeButtonRef = useRef<HTMLButtonElement>(null);
  const { buttonProps: removeButtonProps } = useButton(
    { onPress: () => onRemove(task) },
    removeButtonRef,
  );

  return (
    <div key={task.id} className="flex w-full justify-center">
      <div className="w-1/3 bg-white p-8">
        <div className="group flex justify-between">
          <div className="flex items-center">
            <button
              {...closeButtonProps}
              ref={closeButtonRef}
              title="完了"
              aria-label="完了"
              className="h-5 w-5 rounded-xl border"
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
            {...removeButtonProps}
            ref={removeButtonRef}
            title="削除"
            aria-label="削除"
            className="invisible group-hover:visible"
          >
            <MdClose />
          </button>
        </div>
      </div>
    </div>
  );
};

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
      <CreateTaskForm onSubmit={handleOnSubmit} />
      {tasks.map((task) => (
        <TaskCard
          key={task.id}
          task={task}
          onRemove={handleOnRemove(task)}
          onClose={handleOnClose(task)}
        />
      ))}
    </div>
  );
};

export default TodoListPage;
