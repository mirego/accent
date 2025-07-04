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

  submitTask = dropTask(async (targetLanguageSlug: string) => {
    this.args.onUpdatingText();

    const variables = {
      projectId: this.args.project.id,
      text: this.args.text,
      targetLanguageSlug
    };

    const {data} = await this.apollo.client.query({
      query: projectTranslateTextQuery,
      variables
    });

    if (data.viewer.project.translatedText?.text) {
      this.args.onUpdateText(data.viewer.project.translatedText?.text);
    }
  });
}
