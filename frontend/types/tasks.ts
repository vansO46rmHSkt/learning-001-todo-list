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
