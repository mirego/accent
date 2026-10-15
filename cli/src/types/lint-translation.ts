export interface LintMessage {
  check: string;
  text: string;
}

export interface LintTranslation {
  key: string;
  text: string;
  messages: LintMessage[];
  path: string;
}
