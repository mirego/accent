// Types
import {DocumentConfig} from './document-config';
import {VersionConfig} from './version-config';

export interface Config {
  apiUrl: string;
  apiKey: string;
  project?: string | null;
  version?: VersionConfig;
  files: DocumentConfig[];
}
