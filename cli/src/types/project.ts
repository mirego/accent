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
  translationsCount: number;
  conflictsCount: number;
  reviewedCount: number;
}

export interface Document {
  path: string;
  format: string;
}

export interface PaginatedDocuments {
  entries: Document[];
}

export interface Project {
  id: string;
  name: string;
  lastSyncedAt: string;
  masterRevision: Revision;
  revisions: Revision[];
  documents: PaginatedDocuments;
}
