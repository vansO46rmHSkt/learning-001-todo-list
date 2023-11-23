export const sleep = (delay: number) =>
  new Promise((resolve) => setTimeout(resolve, delay));

export const fetcher = (url: string) => fetch(url).then((res) => res.json());
