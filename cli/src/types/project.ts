export interface Language {
  id: string;
  name: string;
  slug: string;
}

export interface Revision {
  id: string;
  name: string;
  slug: string | null;
  language: Language;
  isMaster: boolean;
  translatedCount: number;
  translationsCount: number;
  conflictsCount: number;
  reviewedCount: number;
}

export interface Document {
  path: string;
  format: string;
}

export interface Version {
  tag: string;
  name: string;
}

export interface Collaborator {
  id: string;
  role: string;
  user: {
    email: string;
    fullname: string;
  };
}

interface DocumentsMeta {
  totalEntries: number;
}

export interface Paginated<T> {
  entries: T[];
  meta: DocumentsMeta;
}

export interface ProjectViewer {
  user: {
    fullname: string;
  };
  project: Project;
}

export interface Project {
  id: string;
  name: string;
  logo: string | null;
  lastSyncedAt: string;
  masterRevision: Revision;
  revisions: Revision[];
  collaborators: Collaborator[];
  documents: Paginated<Document>;
  versions: Paginated<Version>;
}
