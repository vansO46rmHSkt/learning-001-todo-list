import { AttributeValue } from "@aws-sdk/client-dynamodb";

export const SPLITTER = "#" as const;
export const ROOT_TASK_PREFIX = "Root" as const;

export const taskStatus = {
  Draft: "Draft",
  Open: "Open",
  Closed: "Closed",
} as const;
type TaskStatus = keyof typeof taskStatus;

export interface TaskBase {
  id?: string;
  status: TaskStatus;
  parent: string;
  order: number;
  title: string;
  category: string;
  detail: string;
  createdAt?: string;
  updatedAt?: string;
  closedAt?: string;
}

export interface DraftTask extends TaskBase {
  status: "Draft";
}

export interface OpenTask extends TaskBase {
  id: string;
  status: "Open";
  createdAt: string;
  updatedAt: string;
}

export interface ClosedTask extends TaskBase {
  id: string;
  status: "Closed";
  createdAt: string;
  updatedAt: string;
  closedAt: string;
}

export interface TaskItem extends Record<string, AttributeValue> {
  // UserId
  PK_GSI1PK_GSI3PK: {
    S: string;
  };
  // Task#TaskId
  SK: {
    S: string;
  };
  // Status#Parent#Order
  GSI1SK_GSI2SK: {
    S: string;
  };
  // UserId#CategoryId
  GSI2PK: {
    S: string;
  };
  // ClosedAt
  GSI3SK?: {
    S: string;
  };
  Title: {
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

export const openTask = (task: DraftTask | ClosedTask): OpenTask => {
  const now = new Date().toISOString();
  const parent = task.parent || ROOT_TASK_PREFIX;
  const { closedAt, ...rest } = task;
  return {
    ...rest,
    id: crypto.randomUUID(),
    parent,
    status: "Open",
    createdAt: task.createdAt || now,
    updatedAt: now,
  };
};

export const closeTask = (task: OpenTask): ClosedTask => {
  const now = new Date().toISOString();
  return {
    ...task,
    status: "Closed",
    updatedAt: now,
    closedAt: now,
  };
};

export const convertToItem = (
  userId: string,
  task: OpenTask | ClosedTask,
  isCreated = false,
): typeof isCreated extends true ? Required<TaskItem> : TaskItem => {
  return {
    PK_GSI1PK_GSI3PK: {
      S: userId,
    },
    SK: {
      S: `Task${SPLITTER}${task.id}`,
    },
    GSI1SK_GSI2SK: {
      S: `Task${SPLITTER}${task.status}${SPLITTER}${
        task.parent
      }${SPLITTER}${`${task.order}`.padStart(10, "0")}`,
    },
    GSI2PK: {
      S: `${userId}${SPLITTER}${task.category}`,
    },
    Title: {
      S: `${task.title}`,
    },
    Detail: {
      S: task.detail,
    },
    UpdatedAt: {
      S: task.updatedAt,
    },
    ...(isCreated ? { CreatedAt: { S: task.createdAt } } : {}),
    ...(task.closedAt ? { GSI3SK: { S: task.closedAt } } : {}),
  };
};

const getSecondKey = (key: string): string =>
  key.split(SPLITTER).slice(1).join(SPLITTER);

export const convertFromItem = (
  item: Required<TaskItem>,
): OpenTask | ClosedTask => {
  const [, status, parent, order] = item.GSI1SK_GSI2SK.S.split(SPLITTER);
  const id = getSecondKey(item.SK.S);
  const category = getSecondKey(item.GSI2PK.S);
  return {
    id,
    parent,
    order: Number.parseInt(order, 10),
    category,
    status: status as never,
    title: item.Title.S,
    detail: item.Detail.S,
    createdAt: item.CreatedAt.S,
    updatedAt: item.UpdatedAt.S,
    closedAt: item.GSI3SK?.S,
  };
};

export const mergeTask = <T extends TaskBase>(before: T, after: T): T => {
  return ([...Object.keys(after)] as (keyof T)[]).reduce(
    (acc, key) => {
      if (after[key] != null) {
        acc[key] = after[key] as never;
      }
      return acc;
    },
    {
      ...before,
    } as T,
  );
};

export const filterPrimaryKey = (key: string): boolean =>
  !key.startsWith("PK") && !key.startsWith("SK");
