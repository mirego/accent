export interface Translation {
  id: string;
  key: string;
  text: string;
  isConflicted?: boolean;
}

export interface Meta {
  attributeName?: string;
  head?: boolean;
}

const REVISION_KEY = 'accent-current-revision';

/*
  The State is a singleton component that keeps track of references
  used in all components. With the state, you can request a NodeElement from a translation, vice and versa.
*/
export default class State {
  refs = new Map<string, Map<HTMLElement, Meta>>();
  nodes = new WeakMap<HTMLElement, Set<string>>();
  projectTranslations: Record<string, Translation> = {};

  getCurrentRevision() {
    return localStorage.getItem(REVISION_KEY);
  }

  setCurrentRevision(id: string) {
    localStorage.setItem(REVISION_KEY, id);
  }

  removeCurrentRevision() {
    localStorage.removeItem(REVISION_KEY);
  }

  addReference(node: HTMLElement, translation: Translation, meta: Meta = {}) {
    let elements = this.refs.get(translation.id);
    if (!elements) this.refs.set(translation.id, (elements = new Map()));
    elements.set(node, meta);

    let keys = this.nodes.get(node);
    if (!keys) this.nodes.set(node, (keys = new Set()));
    keys.add(translation.key);
  }

  translationById(id: string) {
    return Object.prototype.hasOwnProperty.call(this.projectTranslations, id)
      ? this.projectTranslations[id]
      : undefined;
  }
}
