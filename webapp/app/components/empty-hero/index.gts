import Component from '@glimmer/component';
import {scopedClass} from 'ember-scoped-css';

interface Feature {
  icon: unknown;
  title: string;
  text: string;
}

interface Args {
  title: string;
  text: string;
  icon?: unknown;
  features?: Feature[];
}

export default class EmptyHero extends Component<Args> {
  <template>
    <div class='empty'>
      <div ...attributes class='empty-hero'>
        {{#if @icon}}
          <@icon class={{scopedClass 'empty-hero-icon'}} />
        {{/if}}
        <div>
          <h3 class='empty-hero-title'>{{@title}}</h3>
          <p class='empty-hero-text'>{{@text}}</p>
        </div>
      </div>

      {{#if @features}}
        <ul class='empty-features'>
          {{#each @features as |feature|}}
            <li class='empty-feature'>
              <feature.icon class={{scopedClass 'empty-feature-icon'}} />
              <div>
                <strong>{{feature.title}}</strong>
                <span>{{feature.text}}</span>
              </div>
            </li>
          {{/each}}
        </ul>
      {{/if}}
    </div>

    <style scoped>
      .empty {
        display: flex;
        flex-direction: column;
        gap: 23px;
        margin: 24px 0;
        max-width: 620px;
        padding: 8px 0;
      }

      .empty-hero {
        display: flex;
        gap: 18px;
        align-items: flex-start;
        padding: 14px 16px;
        border-radius: var(--border-radius);
        background: color-mix(in srgb, var(--color-primary) 8%, transparent);
      }

      .empty-hero-icon {
        flex-shrink: 0;
        width: 40px;
        height: 40px;
        color: var(--color-primary);
      }

      .empty-hero-title {
        margin: 0 0 5px;
        font-size: 17px;
        font-weight: 700;
        color: var(--text-color-normal);
      }

      .empty-hero-text {
        margin: 0;
        font-size: 13px;
        line-height: 1.4;
        color: color-mix(in srgb, var(--text-color-normal) 45%, transparent);
      }

      .empty-features {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 26px 32px;
      }

      .empty-feature {
        display: flex;
        gap: 14px;
        align-items: flex-start;
      }
      .empty-feature div {
        display: flex;
        flex-direction: column;
        gap: 4px;
      }
      .empty-feature strong {
        font-size: 13px;
        font-weight: 700;
        color: color-mix(in srgb, var(--text-color-normal) 83%, transparent);
      }
      .empty-feature span {
        font-size: 12px;
        line-height: 1.5;
        color: color-mix(in srgb, var(--text-color-normal) 67%, transparent);
      }

      .empty-feature-icon {
        flex-shrink: 0;
        box-sizing: content-box;
        width: 18px;
        height: 18px;
        padding: 9px;
        border-radius: var(--border-radius);
        color: var(--color-primary);
        background: color-mix(in srgb, var(--color-primary) 12%, transparent);
      }

      @media (max-width: 560px) {
        .empty-features {
          grid-template-columns: 1fr;
          gap: 24px;
        }
      }
    </style>
  </template>
}
