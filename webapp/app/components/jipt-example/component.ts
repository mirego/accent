import Component from '@glimmer/component';

interface ArgsTranslation {
  key: string;
  document: {
    path: string;
  };
}

interface Args {
  project: {
    id: string;
    name: string;
    revision: {
      translations: {
        entries: ArgsTranslation[];
      };
    };
  };
}

export default class JIPTExample extends Component<Args> {
  get scriptSrc() {
    return `${window.location.origin}/static/jipt/index.js`;
  }

  get scriptContent() {
    return `window.accent=window.accent||function(){(accent.q=accent.q||[]).push(arguments);};
      accent('init',{h:'${window.location.origin}',i:'${this.args.project.id}'});`;
  }

  get translationKey() {
    const translation = this.args.project.revision.translations.entries[0];
    return `{^${translation.key}@${translation.document.path}}`;
  }
}
