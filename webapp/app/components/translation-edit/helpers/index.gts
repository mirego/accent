import Component from '@glimmer/component';
import {get} from '@ember/helper';
import InlineMachineTranslate from 'accent-webapp/components/inline-machine-translate/index';
import ImprovePrompt from 'accent-webapp/components/improve-prompt/index';

interface Args {
  revisions: any[];
}

export default class TranslationEditHelpers extends Component<Args> {
  <template>
    <div class='root'>
      {{#if (get @permissions 'machineTranslationsTranslate')}}
        <InlineMachineTranslate
          @rtl={{@rtl}}
          @project={{@project}}
          @text={{@text}}
          @languageSlug={{@languageSlug}}
          @onUpdatingText={{@onUpdatingText}}
          @onUpdateText={{@onUpdateText}}
        />
      {{/if}}

      {{#if (get @permissions 'usePromptImproveText')}}
        <ImprovePrompt
          @rtl={{@rtl}}
          @project={{@project}}
          @prompts={{@prompts}}
          @text={{@text}}
          @onUpdatingText={{@onUpdatingText}}
          @onUpdateText={{@onUpdateText}}
        />
      {{/if}}
    </div>

    <style scoped>
      .root {
        display: flex;
        align-items: center;
        gap: 2px;
      }
    </style>
  </template>
  get machineTranslationLanguages() {
    if (!this.args.revisions) return [];

    return this.args.revisions.map((revision: any) => ({
      name: revision.name || revision.language.name,
      slug: revision.slug || revision.language.slug
    }));
  }
}
