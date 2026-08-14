import Component from '@glimmer/component';
import {service} from '@ember/service';
import {dropTask} from 'ember-concurrency';
import Apollo from 'accent-webapp/services/apollo';
import projectTranslateTextQuery from 'accent-webapp/queries/translate-text-project';
import AsyncButton from 'accent-webapp/components/async-button/index';
import perform from 'ember-concurrency/helpers/perform';
import LanguageSvg from 'accent-webapp/svgs/assets/language.svg';

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
      <LanguageSvg class='button-icon' />
    </AsyncButton>

    <style scoped>
      button.local-button {
        padding-left: 10px;
        padding-right: 10px;
        border-radius: var(--border-radius);
      }
      button.local-button:focus,
      button.local-button:hover {
        transform: translate3d(0, 0, 0);
      }
    </style>
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
