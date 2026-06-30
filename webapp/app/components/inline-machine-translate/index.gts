import Component from '@glimmer/component';
import {service} from '@ember/service';
import {dropTask} from 'ember-concurrency';
import Apollo from 'accent-webapp/services/apollo';
import projectTranslateTextQuery from 'accent-webapp/queries/translate-text-project';
import AsyncButton from 'accent-webapp/components/async-button/index';
import perform from 'ember-concurrency/helpers/perform';
import inlineSvg from 'accent-webapp/helpers/inline-svg';

interface Args {
  text: string;
  project: {id: string};
  onUpdatingText: () => void;
  onUpdateText: (value: string) => void;
}

interface ProjectTranslateTextData {
  viewer: {
    project: {
      translatedText?: {
        text?: string;
      };
    };
  };
}

export default class ImprovePrompt extends Component<Args> {
  <template>
    <AsyncButton
      title={{@languageSlug}}
      @onClick={{perform this.submitTask @languageSlug}}
      @loading={{this.isSubmitting}}
      class='button button--iconOnly button--link button--filled button--white local-button'
    >
      {{inlineSvg '/assets/language.svg' class='button-icon'}}
    </AsyncButton>
  </template>
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

    const {data} = await this.apollo.client.query<ProjectTranslateTextData>({
      query: projectTranslateTextQuery,
      variables
    });

    if (data?.viewer.project.translatedText?.text) {
      this.args.onUpdateText(data.viewer.project.translatedText?.text);
    }
  });
}
