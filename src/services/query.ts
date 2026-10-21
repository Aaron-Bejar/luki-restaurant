type QueryError = {
  message: string;
};

export function requireData<T>(data: T | null, error: QueryError | null): T {
  if (error) {
    throw new Error(error.message);
  }

  if (data === null) {
    throw new Error("La operación no devolvió datos.");
  }

  return data;
}

export function requireSuccess(error: QueryError | null): void {
  if (error) {
    throw new Error(error.message);
  }
}
