import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';
import {on} from '@ember/modifier';
import WarningSvg from 'accent-webapp/svgs/assets/warning.svg';
import XSvg from 'accent-webapp/svgs/assets/x.svg';
import AccModal from 'accent-webapp/components/acc-modal/index';
import {fn, concat} from '@ember/helper';
import {scopedClass} from 'ember-scoped-css';
import t from 'ember-intl/helpers/t';

interface Args {
  message: {
    check: string;
    text: string;
    offset: number | null;
    length: number | null;
  };
  permissions: object;
  create: (lintEntry: object) => Promise<{errors: string[] | null}>;
}

export default class LintTranslationsPageAddLintEntry extends Component<Args> {
  <template>
    <button
      class='button button--iconOnly button--red button--borderless toggle'
      {{on 'click' this.toggleMenu}}
    >
      <XSvg class='button-icon' />
    </button>

    {{#if this.displayMenu}}
      <AccModal @onClose={{fn this.toggleMenu}} @small={{true}}>
        <div class='wrapper'>
          <button class='closeButton' {{on 'click' (fn this.toggleMenu)}}>
            <div class='closeButton-content'>
              <XSvg class={{scopedClass 'closeButton-icon'}} />
            </div>
          </button>

          {{#if this.isSpelling}}
            <strong class='title'>
              <WarningSvg class={{scopedClass 'title-icon'}} />
              {{@message.details.spellingRuleDescription}}
            </strong>
          {{else}}
            <strong class='title'>
              <WarningSvg class={{scopedClass 'title-icon'}} />
              {{t
                (concat
                  'components.translation_edit.lint_message.title_checks.'
                  @message.check
                )
              }}
            </strong>
          {{/if}}

          <div class='actions'>
            {{#if @message.details.spellingRuleId}}
              <button
                class='button button--white button--filled'
                {{on
                  'click'
                  (fn
                    this.create
                    'LANGUAGE_TOOL_RULE_ID'
                    @message.details.spellingRuleId
                  )
                }}
              >
                {{t
                  'components.lint_translations_page.add_lint_entry.ignore_spellcheck_rule'
                }}
                <span class='code'>{{@message.details.spellingRuleId}}</span>
              </button>
            {{/if}}

            {{#if this.spellingTermValue}}
              <button
                class='button button--white button--filled'
                {{on 'click' (fn this.create 'TERM' this.spellingTermValue)}}
              >
                {{t
                  'components.lint_translations_page.add_lint_entry.ignore_checks_for_term'
                }}
                <span class='code'>{{this.spellingTermValue}}</span>
              </button>
            {{/if}}

            <button
              class='button button--white button--filled'
              {{on 'click' (fn this.create 'ALL' null)}}
            >
              {{t
                'components.lint_translations_page.add_lint_entry.ignore_check_for_project'
              }}
              <span class='code'>{{@message.check}}</span>
            </button>

            <button
              class='button button--white button--filled'
              {{on 'click' (fn this.create 'KEY' @translation.key)}}
            >
              {{t
                'components.lint_translations_page.add_lint_entry.ignore_checks_for_key'
              }}
            </button>
          </div>
        </div>
      </AccModal>
    {{/if}}

    <style scoped>
      @charset "UTF-8";
      .toggle {
        position: relative;
        top: -1px;
      }

      .close {
        position: absolute;
        top: 10px;
        right: 10px;
      }

      .wrapper {
        padding: 20px;
        position: relative;
      }
      .wrapper .closeButton {
        position: absolute;
        top: 10px;
        right: 10px;
        padding: 0;
        background: transparent;
      }
      .wrapper .closeButton:focus .closeButton-icon,
      .wrapper .closeButton:hover .closeButton-icon {
        opacity: 1;
      }
      .wrapper .closeButton-content {
        display: flex;
      }
      .wrapper .closeButton-icon {
        width: 20px;
        height: 20px;
        stroke: var(--color-grey);
        opacity: 0.6;
        transition: 0.2s ease-in-out;
        transition-property: opacity;
      }

      .title {
        display: flex;
        align-items: flex-start;
        line-height: 1.2;
        gap: 10px;
        font-size: 20px;
        margin-bottom: 14px;
      }

      .title-icon {
        position: relative;
        top: 5px;
        width: 13px;
        height: 13px;
        opacity: 0.6;
      }

      .actions {
        display: flex;
        flex-direction: column;
        align-items: flex-start;
        gap: 10px;
      }

      .actions button {
        gap: 5px;
      }

      .code {
        font-family: var(--font-monospace);
        color: var(--color-primary);
        opacity: 0.8;
        font-weight: normal;
      }
      .code::before {
        content: '”';
      }
      .code::after {
        content: '“';
      }

      .menu-button {
        background: transparent;
        width: 100%;
        padding: 4px 5px;
        border-radius: var(--border-radius);
        font-size: 12px;
        transition: 0.2s ease-in-out;
        transition-property: background;
        text-align: left;
      }
      .menu-button span {
        display: inline-block;
        background: var(--background-light);
        border: 1px solid var(--background-light-highlight);
        border-radius: 50px;
        padding: 2px 5px;
        font-size: 11px;
      }
      .menu-button:focus,
      .menu-button:hover {
        background: var(--background-light);
      }
    </style>
  </template>
  @tracked
  displayMenu = false;

  get isSpelling() {
    return this.args.message.check === 'SPELLING';
  }

  get spellingTermValue() {
    if (this.args.message.offset == null || this.args.message.length == null)
      return;

    return this.args.message.text.substring(
      this.args.message.offset,
      this.args.message.offset + this.args.message.length
    );
  }

  @action
  toggleMenu() {
    this.displayMenu = !this.displayMenu;
  }

  @action
  async create(type: string, value: string | null) {
    await this.args.create({
      checkIds: [this.args.message.check.toLowerCase()],
      type,
      value
    });

    this.displayMenu = false;
  }
}
