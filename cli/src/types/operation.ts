export interface PeekOperationDetail {
  action: string;
  key: string;
  text: string | null;
  'previous-text': string | null;
}

export interface PeekOperation {
  operations: Record<string, PeekOperationDetail[]>;
  stats: Record<string, Record<string, number>>;
}
