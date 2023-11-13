import { fetcher } from "@/shared/misc";
import { DraftTask, TaskBase, taskStatus } from "@/types/tasks";
import { useReducer, useCallback, useEffect } from "react";
import useSWR from "swr";

const actions: Record<
  string,
  | ((previous: TaskBase[], task: TaskBase) => TaskBase[])
  | ((previous: TaskBase[], tasks: TaskBase[]) => TaskBase[])
> = {
  create: (_: TaskBase[], tasks: TaskBase[]) => [...tasks],
  add: (previous: TaskBase[], task: TaskBase) =>
    [task, ...previous].sort((a, b) => a.order - b.order),
  remove: (previous: TaskBase[], task: TaskBase) =>
    previous.filter((t) => t.id !== task.id).sort((a, b) => a.order - b.order),
} as const;

const useTasks = () => {
  const { data, error } = useSWR<TaskBase[]>(
    `/api/v1/tasks?status=${taskStatus.Open}`,
    fetcher,
  );

  const [tasks, action] = useReducer(
    (
      previous: TaskBase[],
      {
        type,
        task,
      }: { type: keyof typeof actions; task: TaskBase | TaskBase[] },
    ) => actions[type](previous, task as never),
    [...(data || [])],
  );

  useEffect(() => {
    if (data) {
      action({ type: "create", task: data });
    }
  }, [data]);

  const createTask = useCallback(
    async (title: string) => {
      if (!title) return;
      const draft: DraftTask = {
        order: tasks.length + 1,
        parent: "",
        title,
        category: "",
        detail: "",
        status: "Draft",
      };
      const response = await fetch("/api/v1/tasks", {
        method: "POST",
        body: JSON.stringify(draft),
      });
      const task = await response.json();
      if (response.status === 201) {
        action({ type: "add", task });
      }
    },
    [tasks],
  );

  const removeTask = useCallback(async (task: TaskBase) => {
    const status = await fetch(`/api/v1/tasks/${task.id}`, {
      method: "DELETE",
    }).then((res) => res.status);
    if (status === 204) {
      action({ type: "remove", task });
    }
  }, []);

  const closeTask = useCallback(async (task: TaskBase) => {
    const status = await fetch(`/api/v1/tasks/${task.id}`, {
      method: "PUT",
      body: JSON.stringify({
        status: taskStatus.Closed,
      }),
    }).then((res) => res.status);
    if (status === 200) {
      action({ type: "remove", task });
    }
  }, []);

  return {
    tasks,
    isLoading: !error && !data,
    isError: error,
    actions: {
      createTask,
      removeTask,
      closeTask,
    },
  };
};

export default useTasks;
