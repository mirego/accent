const randomId = () => Math.random().toString(36).substring(2);

export const fakeProject = (params?: object) => ({
  __typename: 'Project',
  id: `project-id-${randomId()}`,
  conflictsCount: 0,
  lastSyncedAt: '2020-02-05T20:00:00Z',
  logo: null,
  mainColor: '#28cb87',
  name: 'Accent',
  translationsCount: 420,
  ...params,
});

export const fakeLanguage = (params?: object) => ({
  __typename: 'Language',
  id: `language-id-${randomId()}`,
  name: 'French',
  slug: 'fr',
  ...params,
});
