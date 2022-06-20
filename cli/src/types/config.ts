// Types
import {DocumentConfig} from './document-config';

export interface Config {
  apiUrl: string;
  apiKey: string;
  project: string | null | undefined;
  files: DocumentConfig[];
}
