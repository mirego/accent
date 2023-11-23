import Component from '@glimmer/component';
import {inject as service} from '@ember/service';
import {dropTask} from 'ember-concurrency-decorators';
import {taskFor} from 'ember-concurrency-ts';
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
  apollo: Apollo;

  get isSubmitting() {
    return taskFor(this.submitTask).isRunning;
  }

  @dropTask
  *submitTask(targetLanguageSlug: string) {
    this.args.onUpdatingText();

    const variables = {
      projectId: this.args.project.id,
      text: this.args.text,
      targetLanguageSlug,
    };

    const {data} = yield this.apollo.client.query({
      query: projectTranslateTextQuery,
      variables,
    });

    if (data.viewer.project.translatedText?.text) {
      this.args.onUpdateText(data.viewer.project.translatedText?.text);
    }
  }
}
