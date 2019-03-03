interface RefState {
  elements: Map<HTMLElement, object>;
}

interface NodeState {
  keys: Set<string>;
  meta: object;
}

interface Translation {
  id: string;
  key: string;
  text: string;
}

/*
  The State is a singleton component that keeps track of references
  used in all components. With the state, you can request a NodeElement from a translation, vice and versa.
*/
export default class State {
  refs: Map<string, RefState>;
  nodes: Map<HTMLElement, NodeState>;
  projectTranslations: Map<string, Translation>;

  constructor(properties) {
    this.refs = properties.refs;
    this.nodes = properties.nodes;
    this.projectTranslations = properties.projectTranslations;
  }

  getCurrentRevision() {
    return localStorage.getItem('current-revision');
  }

  setCurrentRevision(id: string) {
    localStorage.setItem('current-revision', id);
  }

  addReference(node, translation, meta = {}) {
    this.addTranslationRef(translation, node, meta);
    this.addNodeRef(node, translation);
  }

  translationById(id: string) {
    return this.projectTranslations[id];
  }

  private addTranslationRef(translation, node, meta = {}) {
    const match = this.refs.get(translation.id);
    const elements = match ? match.elements : new Map();
    elements.set(node, meta);

    this.refs.set(translation.id, {elements});
  }

  private addNodeRef(node, translation, meta = {}) {
    const match = this.nodes.get(node);
    const keys = match ? match.keys : new Set();
    keys.add(translation.key);

    this.nodes.set(node, {keys, meta});
  }
}
