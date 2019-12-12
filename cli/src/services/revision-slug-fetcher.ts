// Types
import {Project, Revision} from '../types/project';

export const fetchNameFromRevision = (revision: Revision): string => {
  return revision.name || revision.language.name;
};

export const fetchFromRevision = (revision: Revision): string => {
  return revision.slug || revision.language.slug;
};

export const fetchFromRevisions = (revisions: Revision[]): string[] => {
  return revisions.map(fetchFromRevision);
};

export const fetchMasterFromProject = (project: Project): string => {
  const masterRevision = project.revisions.find(({isMaster}) => isMaster);

  return fetchFromRevision(masterRevision!);
};
