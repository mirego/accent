import Component from '@glimmer/component';
import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';
import t from 'ember-intl/helpers/t';
import {concat, get, fn, array} from '@ember/helper';
import {on} from '@ember/modifier';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import AddLintEntry from 'accent-webapp/components/lint-translations-page/add-lint-entry/index';
import {LinkTo} from '@ember/routing';
import stringDiff from 'accent-webapp/helpers/string-diff';

interface Args {
  lintTranslation: any;
  fix?: (lintTranslation: any, message: any) => void;
}

const escape = document.createElement('textarea');
const escapeHTML = (html: string): string => {
  escape.textContent = html;
  return escape.innerHTML;
};

export default class LintTranslationsPageItem extends Component<Args> {
  <template>
    {{#if @lintTranslation.messages}}
      <div
        class='lint-translations-item wrapper
          {{if @project "wrapper--project"}}'
      >
        <div>
          <ul class='messages'>
            {{#each this.messages as |message|}}
              <li class='messages-item'>
                <span class='description'>
                  {{#if message.message}}
                    {{message.message}}
                  {{else}}
                    {{t
                      (concat
                        'components.translation_edit.lint_message.checks.'
                        message.check
                      )
                    }}
                  {{/if}}
                </span>

                <div class='messages-item-actions'>
                  {{#if (get @permissions 'updateTranslation')}}
                    {{#if message.replacement}}
                      {{#if @fixText}}
                        <button
                          {{on
                            'click'
                            (fn @fixText @lintTranslation.translation message)
                          }}
                          class='button--iconOnly button button--borderless button--sm button--green button-fix'
                        >
                          {{inlineSvg '/assets/check.svg' class='button-icon'}}
                        </button>
                      {{/if}}
                    {{/if}}
                  {{/if}}

                  {{#if (get @permissions 'createProjectLintEntry')}}
                    {{#if @createLintEntry}}
                      <AddLintEntry
                        @create={{@createLintEntry}}
                        @message={{message}}
                        @translation={{@lintTranslation.translation}}
                      />
                    {{/if}}
                  {{/if}}
                </div>
              </li>
            {{/each}}
          </ul>
        </div>

        {{#if @project}}
          <div class='details'>
            <LinkTo
              @route='logged-in.project.translation'
              @models={{array @project.id @lintTranslation.translation.id}}
              class='item-link'
            >
              <strong class='item-key'>
                {{this.translationKey.value}}
                <small class='item-key-prefix'>
                  {{#if this.translationKey.prefix}}
                    {{this.translationKey.prefix}}
                  {{else}}
                    {{@lintTranslation.translation.document.path}}
                  {{/if}}
                </small>
              </strong>
            </LinkTo>
          </div>
        {{/if}}

        {{#if this.allReplacable}}
          <ul>
            {{#each this.messages as |message|}}
              {{#if message.replacement}}
                <li class='item-diff-text'>
                  <div>
                    {{stringDiff message.replacement.value message.text}}
                  </div>

                  {{#if @changeText}}
                    <button
                      {{on 'click' (fn @changeText message.replacement.value)}}
                      class='button button--iconOnly button--borderless button--grey'
                    >
                      {{inlineSvg '/assets/redo.svg' class='button-icon'}}
                    </button>
                  {{/if}}
                </li>
              {{/if}}
            {{/each}}
          </ul>
        {{else}}
          <div class='item-text'>{{{this.annotatedText}}}</div>
        {{/if}}
      </div>
    {{/if}}
  </template>
  translationKey = parsedKeyProperty(this.args.lintTranslation.translation.key);

  get allReplacable() {
    return this.args.lintTranslation.messages.every(
      (message: {replacement: object | null}) => {
        return Boolean(message.replacement);
      }
    );
  }

  get messages() {
    const mapSet = new Set();
    return this.args.lintTranslation.messages.flatMap((message: any) => {
      if (mapSet.has(message.check)) {
        return [];
      } else {
        mapSet.add(message.check);
        return [message];
      }
    });
  }

  get annotatedText() {
    let offsetTotal = 0;

    let text = [...this.args.lintTranslation.messages]
      .sort((a: any, b: any) => (a.offset || 0) - (b.offset || 0))
      .reduce((text: string, message: any) => {
        if (message.length) {
          const error = text.slice(
            message.offset + offsetTotal,
            message.offset + message.length + offsetTotal
          );

          if (message.replacement) {
            const replacement = `(span data-underline)${error}(/span)(strong)${message.replacement.label}(/strong)`;
            offsetTotal += replacement.length - error.length;

            return String(text).replace(error, replacement);
          } else {
            const replacement = `(span data-underline)${error}(/span)`;

            offsetTotal += replacement.length - error.length;

            return String(text).replace(error, replacement);
          }
        } else if (message.check === 'LEADING_SPACES') {
          const replacement = `(span data-rect) (/span)`;
          offsetTotal += replacement.length - 1;

          return String(text).replace(/^ /, replacement);
        } else if (message.check === 'TRAILING_SPACE') {
          const replacement = `(span data-rect) (/span)`;
          offsetTotal += replacement.length - 1;

          return String(text).replace(/ $/, replacement);
        } else {
          return text;
        }
      }, this.args.lintTranslation.messages[0].text) as string;

    text = escapeHTML(text);
    text = text.replaceAll('(span data-underline)', '<span data-underline>');
    text = text.replaceAll('(span data-rect)', '<span data-rect>');
    text = text.replaceAll('(/span)', '</span>');
    text = text.replaceAll('(/strong)', '</strong>');
    text = text.replaceAll('(strong)', '<strong>');

    return text;
  }
}
