import { AttributeValue } from "@aws-sdk/client-dynamodb";

const SPLITTER = "#" as const;
const ROOT_TASK_PREFIX = "Root" as const;

type TaskStatus = "normal" | "important" | "closed";

export interface DraftTask {
  parent?: string;
  order: number;
  title: string;
  category?: string;
  status?: TaskStatus;
  detail?: string;
}

export interface Task extends Required<DraftTask> {
  id: string;
  parent: string;
  createdAt: string;
  updatedAt: string;
}

export interface TaskItem extends Record<string, AttributeValue> {
  UserId: {
    S: string;
  };
  TaskId: {
    S: string;
  };
  Parent_Order: {
    S: string;
  };
  UserId_Title: {
    S: string;
  };
  UserId_Category: {
    S: string;
  };
  UserId_Status: {
    S: string;
  };
  Detail: {
    S: string;
  };
  CreatedAt?: {
    S: string;
  };
  UpdatedAt: {
    S: string;
  };
}

export const draftToTask = (draft: DraftTask): Task => {
  const now = new Date().toISOString();
  const parent = draft.parent || ROOT_TASK_PREFIX;
  const category = draft.category ?? "";
  const detail = draft.detail ?? "";
  return {
    ...draft,
    id: crypto.randomUUID(),
    parent,
    category,
    detail,
    status: "normal",
    createdAt: now,
    updatedAt: now,
  };
};

export const convertToItem = (
  userId: string,
  task: Task,
  isCreated = false,
): typeof isCreated extends true ? Required<TaskItem> : TaskItem => {
  return {
    UserId: {
      S: userId,
    },
    TaskId: {
      S: task.id,
    },
    Parent_Order: {
      S: `${task.parent}${SPLITTER}${`${task.order}`.padStart(10, "0")}`,
    },
    UserId_Title: {
      S: `${userId}${SPLITTER}${task.title}`,
    },
    UserId_Category: {
      S: `${userId}${SPLITTER}${task.category}`,
    },
    UserId_Status: {
      S: `${userId}${SPLITTER}${task.status}`,
    },
    Detail: {
      S: task.detail,
    },
    ...(isCreated ? { CreatedAt: { S: task.createdAt } } : {}),
    UpdatedAt: {
      S: task.updatedAt,
    },
  };
};

const getSecondKey = (key: string): string =>
  key.split(SPLITTER).slice(1).join(SPLITTER);

export const convertFromItem = (item: Required<TaskItem>): Task => {
  const [parent, order] = item.Parent_Order.S.split(SPLITTER);
  const title = getSecondKey(item.UserId_Title.S);
  const category = getSecondKey(item.UserId_Category.S);
  const status = getSecondKey(item.UserId_Status.S);
  return {
    id: item.TaskId.S,
    parent,
    order: Number.parseInt(order, 10),
    title,
    category,
    status: status as never,
    detail: item.Detail.S,
    createdAt: item.CreatedAt.S,
    updatedAt: item.UpdatedAt.S,
  };
};
