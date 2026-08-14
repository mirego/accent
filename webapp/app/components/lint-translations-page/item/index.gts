import Component from '@glimmer/component';
import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';
import t from 'ember-intl/helpers/t';
import {concat, get, fn, array} from '@ember/helper';
import {on} from '@ember/modifier';
import CheckSvg from 'accent-webapp/svgs/assets/check.svg';
import RedoSvg from 'accent-webapp/svgs/assets/redo.svg';
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
                          <CheckSvg class='button-icon' />
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
                      <RedoSvg class='button-icon' />
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

    <style scoped>
      .wrapper {
        display: flex;
        flex-direction: column;
      }

      .details {
        padding-right: 25px;
      }

      .messages {
        margin-top: 2px;
        display: flex;
        flex-direction: column;
      }

      .messages-item {
        display: flex;
        gap: 3px;
        align-items: center;
      }
      .messages-item:hover .messages-item-actions button,
      .messages-item:focus .messages-item-actions button {
        opacity: 1;
      }

      .messages-item-actions {
        display: flex;
        gap: 2px;
        align-items: center;
      }

      .messages-item-actions button {
        padding-left: 2px;
        padding-right: 2px;
        opacity: 0.6;
      }

      .description {
        color: var(--color-error);
        font-size: 12px;
      }

      .item-language {
        font-size: 11px;
        font-weight: bold;
        color: var(--color-black);
        opacity: 0.6;
        text-decoration: none;
        transition: 0.2s ease-in-out;
        transition-property: opacity;
      }
      .item-language:focus,
      .item-language:hover {
        opacity: 0.9;
      }

      .item-link {
        text-decoration: none;
      }
      .item-link:focus .item-key,
      .item-link:hover .item-key {
        color: var(--color-primary);
      }

      .item-key-prefix {
        display: block;
        color: #959595;
        font-weight: 300;
        flex-shrink: 0;
      }
      .item-key-prefix::before {
        content: '/';
        margin-right: -5px;
      }

      .item-key {
        display: flex;
        gap: 5px;
        transition: 0.2s ease-in-out;
        transition-property: color;
        margin-right: 15px;
        color: var(--text-color-normal);
        line-height: 1.5;
        word-break: break-all;
        font-family: var(--font-monospace);
        font-size: 11px;
        font-weight: bold;
      }

      .item-text {
        display: block;
        width: 100%;
        font-size: 13px;
        color: var(--text-color-normal);
        padding: 0;
        cursor: text;
        white-space: pre-wrap;
        transition: 0.2s ease-in-out;
        transition-property: opacity;
        opacity: 0.8;
      }
      .item-text.item-text--empty {
        font-style: italic;
        font-size: 11px;
        color: #ddd;
      }
      .item-text:hover,
      .item-text:focus {
        opacity: 1;
      }

      .item-diff-text {
        font-size: 13px;
        color: var(--text-color-normal);
      }
      .item-diff-text > div {
        display: inline;
      }

.item-text :global(.added) {
  padding: 0 1px;
  background: hsl(
    var(--color-green-hue),
    var(--color-green-saturation),
    var(--color-highlight-lighteness)
  );
  color: var(--color-green);
}

.item-text :global(.undiffable) {
  padding: 0 1px;
  background: var(--background-light-highlight);
  color: var(--color-gray);
}

.item-text :global([data-underline]) {
  text-decoration: underline wavy red;
}

.item-text :global(.removed) {
  padding: 0 1px;
  background: hsl(
    var(--color-error-hue),
    var(--color-error-saturation),
    var(--color-highlight-lighteness)
  );
  color: var(--color-error);
  text-decoration: line-through;
}

      .item-text :global(strong) {
        color: var(--color-green);
        margin-left: 4px;
        font-weight: normal;
      }
      .item-text span[data-underline] {
        position: relative;
        text-decoration-line: underline;
        text-decoration-style: wavy;
        text-decoration-color: var(--color-error);
        text-decoration-skip-ink: none;
        text-decoration-thickness: 1px;
      }
      .item-text span[data-rect] {
        position: relative;
        background-color: var(--color-error);
        padding: 0 2px;
        opacity: 0.4;
      }
    </style>
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
