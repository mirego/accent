import Component from '@glimmer/component';
import {service} from '@ember/service';
import {dropTask} from 'ember-concurrency';
import Apollo from 'accent-webapp/services/apollo';

import projectTranslateTextQuery from 'accent-webapp/queries/translate-text-project';

interface Args {
  text: string;
  project: {id: string};
  onUpdatingText: () => void;
  onUpdateText: (value: string) => void;
}

export default class ImprovePrompt extends Component<Args> {
  @service('apollo')
  declare apollo: Apollo;

  get isSubmitting() {
    return this.submitTask.isRunning;
  }

  get isMainLanguage() {
    // Split region as it's not important for translations
    return (
      this.args.languageSlug.split('-')[0] ===
      this.args.project.revisions
        .filter((r) => r.isMaster)[0]
        .language.slug.split('-')[0]
    );
  }

  submitTask = dropTask(async (targetLanguageSlug: string) => {
    this.args.onUpdatingText();

    const sourceLanguageSlug: string = this.args.project.revisions.filter(
      (r) => r.isMaster,
    )[0].language.slug;

    const variables = {
      projectId: this.args.project.id,
      text: this.args.text,
      targetLanguageSlug,
      sourceLanguageSlug:
        sourceLanguageSlug === targetLanguageSlug
          ? undefined
          : sourceLanguageSlug,
    };

    const {data} = await this.apollo.client.query({
      query: projectTranslateTextQuery,
      variables,
    });

    if (data.viewer.project.translatedText?.text) {
      this.args.onUpdateText(data.viewer.project.translatedText?.text);
    }
  });
}
