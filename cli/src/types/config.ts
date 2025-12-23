import {DocumentConfig} from './document-config';
import {VersionConfig} from './version-config';

export interface Config {
  apiUrl: string;
  apiKey: string;
  extraHeaders?: Record<string, string>;
  project?: string | null;
  version?: VersionConfig;
  files: DocumentConfig[];
}
