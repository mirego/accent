import {tracked} from '@glimmer/tracking';
import Service from '@ember/service';

const STORE_KEY = 'accent-recent-projects';
const MAXIMUM_NUMBER_OF_STORED_PROJECTS = 4;

export default class RecentProjects extends Service {
  @tracked
  projectIds: string[] = [];

  add(projectId: string) {
    let storage = this.fetch();
    if (storage.includes(projectId)) return storage;

    storage.unshift(projectId);
    storage = storage.slice(0, MAXIMUM_NUMBER_OF_STORED_PROJECTS);

    this.updateStorage(storage);

    return storage;
  }

  fetch() {
    return this.fetchStorage();
  }

  private fetchStorage(): string[] {
    try {
      const storage = localStorage.getItem(STORE_KEY) || '[]';

      return Array.from(JSON.parse(storage));
    } catch (_) {
      return [];
    }
  }

  private updateStorage(storage: string[]): void {
    try {
      const value = JSON.stringify(storage);
      localStorage.setItem(STORE_KEY, value);
    } catch (_) {
      return;
    }
  }
}

declare module '@ember/service' {
  interface Registry {
    'recent-projects': RecentProjects;
  }
}
