import Component from '@glimmer/component';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';

interface Args {
  error?: any;
  label?: any;
  helpLinkTitle?: any;
  helpLinkHref?: any;
  placeholder?: any;
  value?: any;
  onChange: any;
}

export default class DataControlText extends Component<Args> {
  <template>
    <div class='data-control {{if @error "error-control"}}'>
      <label class='data-title'>
        {{@label}}

        {{#if @helpLinkTitle}}
          <a
            target='_blank'
            rel='noopener noreferrer'
            href={{@helpLinkHref}}
            class='data-title-help'
          >
            {{@helpLinkTitle}}
          </a>
        {{/if}}
      </label>

      <input
        placeholder={{@placeholder}}
        value={{@value}}
        class='textInput'
        {{on 'keyup' (fn @onChange)}}
      />
    </div>
  </template>
}
