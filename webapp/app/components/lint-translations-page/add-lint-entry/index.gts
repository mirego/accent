import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';
import {on} from '@ember/modifier';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
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
      {{inlineSvg '/assets/x.svg' class='button-icon'}}
    </button>

    {{#if this.displayMenu}}
      <AccModal @onClose={{fn this.toggleMenu}} @small={{true}}>
        <div class='wrapper'>
          <button class='closeButton' {{on 'click' (fn this.toggleMenu)}}>
            <div class='closeButton-content'>
              {{inlineSvg
                '/assets/x.svg'
                class=(scopedClass 'closeButton-icon')
              }}
            </div>
          </button>

          {{#if this.isSpelling}}
            <strong class='title'>
              {{inlineSvg
                '/assets/warning.svg'
                class=(scopedClass 'title-icon')
              }}
              {{@message.details.spellingRuleDescription}}
            </strong>
          {{else}}
            <strong class='title'>
              {{inlineSvg
                '/assets/warning.svg'
                class=(scopedClass 'title-icon')
              }}
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
