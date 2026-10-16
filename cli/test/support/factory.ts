import {Project, Revision} from '../../src/types/project';

export type {Project};

export const buildRevision = (
  slug: string,
  attributes: Partial<Revision> = {}
): Revision => ({
  id: `revision-${slug}`,
  name: '',
  slug: null,
  language: {id: `language-${slug}`, name: slug.toUpperCase(), slug},
  isMaster: false,
  translatedCount: 10,
  translationsCount: 10,
  conflictsCount: 0,
  reviewedCount: 10,
  ...attributes
});

export const buildProject = (attributes: Partial<Project> = {}): Project => {
  const master = buildRevision('en', {isMaster: true});
  const revisions = attributes.revisions ?? [master, buildRevision('fr')];

  return {
    id: 'project-id',
    name: 'My project',
    logo: null,
    lastSyncedAt: '2026-01-01T00:00:00Z',
    masterRevision: revisions.find(({isMaster}) => isMaster) ?? master,
    revisions,
    collaborators: [],
    documents: {entries: [], meta: {totalEntries: 0}},
    versions: {entries: [], meta: {totalEntries: 0}},
    ...attributes
  };
};
