export interface Language {
  id: string
  name: string
  slug: string
}

export interface Revision {
  id: string
  language: Language
  translationsCount: number
  conflictsCount: number
  reviewedCount: number
}

export interface Document {
  path: string
  format: string
}

export interface PaginatedDocuments {
  entries: Document[]
}

export interface Project {
  id: string
  name: string
  lastSyncedAt: string
  language: Language
  revisions: Revision[]
  documents: PaginatedDocuments
}
