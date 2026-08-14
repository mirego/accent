import Component from '@glimmer/component';
import t from 'ember-intl/helpers/t';
import {htmlSafe} from '@ember/template';
import {scopedClass} from 'ember-scoped-css';
import SyncSvg from 'accent-webapp/svgs/assets/sync.svg';
import MergeSvg from 'accent-webapp/svgs/assets/merge.svg';
import CheckSvg from 'accent-webapp/svgs/assets/check.svg';
import CheckCircleSvg from 'accent-webapp/svgs/assets/check-circle.svg';
import WarningSvg from 'accent-webapp/svgs/assets/warning.svg';

export default class CommitFileInstructions extends Component {
  <template>
    <div class='instructions'>
      <div class='cards'>
        <div class='card card--sync'>
          <div class='card-header'>
            <span class='card-icon'>
              <SyncSvg class={{scopedClass 'card-iconSvg'}} />
            </span>
            <a
              rel='noopener noreferrer'
              href='https://www.accent.reviews/guides/glossary.html#sync'
              target='_blank'
              class='card-title'
            >
              {{t 'components.commit_file.instructions.sync.title'}}
            </a>
          </div>

          <p class='card-text'>
            {{htmlSafe (t 'components.commit_file.instructions.sync.text')}}
          </p>
        </div>

        <div class='card card--merge'>
          <div class='card-header'>
            <span class='card-icon'>
              <MergeSvg class={{scopedClass 'card-iconSvg'}} />
            </span>
            <a
              rel='noopener noreferrer'
              href='https://www.accent.reviews/guides/glossary.html#add-translations'
              target='_blank'
              class='card-title'
            >
              {{t 'components.commit_file.instructions.merge.title'}}
            </a>
          </div>

          <p class='card-text'>
            {{htmlSafe (t 'components.commit_file.instructions.merge.text')}}
          </p>
        </div>
      </div>

      <div class='modes'>
        <h3 class='modes-title'>
          {{t 'components.commit_file.instructions.modes.title'}}
        </h3>
        <p class='modes-intro'>
          {{t 'components.commit_file.instructions.modes.intro'}}
        </p>
        <div class='modes-tableWrapper'>
          <table class='modes-table'>
            <thead>
              <tr>
                <th>{{t 'components.commit_file.instructions.modes.col_situation'}}</th>
                <th class='col-smart'>{{t 'components.commit_file.instructions.modes.col_smart'}}</th>
                <th>{{t 'components.commit_file.instructions.modes.col_passive'}}</th>
                <th>{{t 'components.commit_file.instructions.modes.col_force'}}</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>{{t 'components.commit_file.instructions.modes.row_same'}}</td>
                <td class='col-smart'>
                  <span class='pill pill--neutral'>
                    <CheckSvg class={{scopedClass 'pill-icon'}} />
                    {{t 'components.commit_file.instructions.modes.cell_nothing'}}
                  </span>
                </td>
                <td>
                  <span class='pill pill--neutral'>
                    <CheckSvg class={{scopedClass 'pill-icon'}} />
                    {{t 'components.commit_file.instructions.modes.cell_nothing'}}
                  </span>
                </td>
                <td>
                  <span class='pill pill--neutral'>
                    <CheckSvg class={{scopedClass 'pill-icon'}} />
                    {{t 'components.commit_file.instructions.modes.cell_nothing'}}
                  </span>
                </td>
              </tr>
              <tr>
                <td>{{t 'components.commit_file.instructions.modes.row_edited'}}</td>
                <td class='col-smart'>
                  <span class='pill pill--positive'>
                    <CheckCircleSvg class={{scopedClass 'pill-icon'}} />
                    {{t 'components.commit_file.instructions.modes.cell_kept'}}
                  </span>
                </td>
                <td>
                  <span class='pill pill--neutral'>
                    <CheckSvg class={{scopedClass 'pill-icon'}} />
                    {{t 'components.commit_file.instructions.modes.cell_untouched'}}
                  </span>
                </td>
                <td>
                  <span class='pill pill--warning'>
                    <WarningSvg class={{scopedClass 'pill-icon'}} />
                    {{t 'components.commit_file.instructions.modes.cell_overwritten_review'}}
                  </span>
                </td>
              </tr>
              <tr>
                <td>{{t 'components.commit_file.instructions.modes.row_changed'}}</td>
                <td class='col-smart'>
                  <span class='pill pill--warning'>
                    <WarningSvg class={{scopedClass 'pill-icon'}} />
                    {{t 'components.commit_file.instructions.modes.cell_overwritten_review'}}
                  </span>
                </td>
                <td>
                  <div class='pillStack'>
                    <span class='pill pill--sync'>
                      <SyncSvg class={{scopedClass 'pill-icon'}} />
                      {{t 'components.commit_file.instructions.modes.cell_passive_sync'}}
                    </span>
                    <span class='pill pill--merge'>
                      <MergeSvg class={{scopedClass 'pill-icon'}} />
                      {{t 'components.commit_file.instructions.modes.cell_passive_merge'}}
                    </span>
                  </div>
                </td>
                <td>
                  <span class='pill pill--warning'>
                    <WarningSvg class={{scopedClass 'pill-icon'}} />
                    {{t 'components.commit_file.instructions.modes.cell_overwritten_review'}}
                  </span>
                </td>
              </tr>
              <tr>
                <td>{{t 'components.commit_file.instructions.modes.row_both'}}</td>
                <td class='col-smart'>
                  <span class='pill pill--warning'>
                    <WarningSvg class={{scopedClass 'pill-icon'}} />
                    {{t 'components.commit_file.instructions.modes.cell_overwritten_review'}}
                  </span>
                </td>
                <td>
                  <span class='pill pill--neutral'>
                    <CheckSvg class={{scopedClass 'pill-icon'}} />
                    {{t 'components.commit_file.instructions.modes.cell_untouched'}}
                  </span>
                </td>
                <td>
                  <span class='pill pill--warning'>
                    <WarningSvg class={{scopedClass 'pill-icon'}} />
                    {{t 'components.commit_file.instructions.modes.cell_overwritten_review'}}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <ul class='modes-notes'>
          <li>{{t 'components.commit_file.instructions.modes.note_force'}}</li>
          <li>{{t 'components.commit_file.instructions.modes.note_keys'}}</li>
          <li>{{t 'components.commit_file.instructions.modes.note_correct'}}</li>
        </ul>
      </div>

      <div class='mistakes'>
        <div class='mistakes-body'>
          <h3 class='mistakes-title'>
            {{t 'components.commit_file.instructions.mistakes.title'}}
          </h3>
          <ul class='mistakes-list'>
            <li class='mistakes-item'>
              {{t 'components.commit_file.instructions.mistakes.item_1'}}
            </li>
            <li class='mistakes-item'>
              {{t 'components.commit_file.instructions.mistakes.item_2'}}
            </li>
            <li class='mistakes-item'>
              {{t 'components.commit_file.instructions.mistakes.item_3'}}
            </li>
          </ul>
        </div>
      </div>
    </div>

    <style scoped>
      .instructions {
        display: flex;
        flex-direction: column;
        gap: 18px;
      }

      .cards {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 16px;
      }

      .card {
        display: flex;
        flex-direction: column;
        gap: 12px;
        padding: 16px;
        border-radius: var(--border-radius);
        background: var(--background-light);
      }

      .card-header {
        display: flex;
        align-items: center;
        gap: 10px;
      }

      .card-icon {
        display: inline-flex;
        flex-shrink: 0;
        align-items: center;
        justify-content: center;
        box-sizing: content-box;
        width: 18px;
        height: 18px;
        padding: 9px;
        border-radius: var(--border-radius);
        background: color-mix(in srgb, var(--color-primary) 12%, transparent);
      }
      .card--merge {
        background: transparent;
      }

      .card--merge .card-icon {
        background: color-mix(in srgb, var(--color-blue) 12%, transparent);
      }
      .card-iconSvg {
        width: 18px;
        height: 18px;
        stroke: var(--color-primary);
      }
      .card--merge .card-iconSvg {
        stroke: var(--color-blue);
      }

      .card-title {
        font-size: 15px;
        font-weight: 700;
        color: var(--text-color-normal);
        text-decoration: none;
      }
      .card-title:hover {
        color: var(--color-primary);
        text-decoration: underline;
      }
      .card--merge .card-title:hover {
        color: var(--color-blue);
      }

      .card-text {
        margin: 0;
        font-size: 13px;
        line-height: 1.5;
        color: color-mix(in srgb, var(--text-color-normal) 70%, transparent);
      }
      .card-text :global(em) {
        display: inline;
        font-style: normal;
        font-weight: 700;
        color: var(--color-primary);
      }
      .card--merge .card-text :global(em) {
        color: var(--color-blue);
      }

      .modes {
        display: flex;
        flex-direction: column;
        gap: 10px;
        padding: 16px;
        border-radius: var(--border-radius);
        background: var(--background-light);
      }

      .modes-title {
        margin: 0;
        font-size: 15px;
        font-weight: 700;
        color: var(--text-color-normal);
      }

      .modes-intro {
        margin: 0;
        font-size: 12px;
        line-height: 1.5;
        color: color-mix(in srgb, var(--text-color-normal) 70%, transparent);
      }

      .modes-tableWrapper {
        overflow-x: auto;
      }

      .modes-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 12px;
      }

      .modes-table th {
        padding: 8px 10px;
        text-align: left;
        font-weight: 600;
        color: var(--text-color-normal);
        background: color-mix(in srgb, var(--background-light) 60%, var(--content-background));
        border-bottom: 1px solid var(--background-light-highlight);
      }

      .modes-table td {
        padding: 8px 10px;
        color: color-mix(in srgb, var(--text-color-normal) 75%, transparent);
        border-bottom: 1px solid var(--background-light-highlight);
      }

      .modes-table td:first-child {
        font-weight: 500;
      }

      .modes-table tbody tr:hover td {
        background: color-mix(in srgb, var(--background-light) 60%, var(--content-background));
      }

      .modes-table .col-smart {
        background: color-mix(in srgb, var(--color-primary) 6%, transparent);
      }

      .modes-table th.col-smart {
        color: var(--color-primary);
      }

      .pill {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        font-weight: 500;
        white-space: nowrap;
      }

      .pill-icon {
        width: 13px;
        height: 13px;
        flex-shrink: 0;
      }

      .pill--neutral {
        color: color-mix(in srgb, var(--text-color-normal) 55%, transparent);
      }
      .pill--neutral .pill-icon {
        stroke: color-mix(in srgb, var(--text-color-normal) 45%, transparent);
      }

      .pill--positive {
        color: var(--color-green);
      }
      .pill--positive .pill-icon {
        stroke: var(--color-green);
      }

      .pill--warning {
        color: var(--color-warning);
      }
      .pill--warning .pill-icon {
        stroke: var(--color-warning);
      }

      .pill--sync {
        color: color-mix(in srgb, var(--text-color-normal) 75%, transparent);
      }
      .pill--sync .pill-icon {
        stroke: var(--color-primary);
      }

      .pill--merge {
        color: var(--color-blue);
      }
      .pill--merge .pill-icon {
        stroke: var(--color-blue);
      }

      .pillStack {
        display: flex;
        flex-direction: column;
        gap: 6px;
      }

      .modes-notes {
        display: flex;
        flex-direction: column;
        gap: 4px;
        margin: 0;
        padding-left: 8px;
        font-size: 11px;
        line-height: 1.5;
        color: color-mix(in srgb, var(--text-color-normal) 65%, transparent);
      }

      .mistakes {
        display: flex;
        gap: 14px;
        align-items: flex-start;
        padding: 14px 16px;
        border-radius: var(--border-radius);
        background: color-mix(in srgb, var(--color-warning) 10%, transparent);
      }

      .mistakes-iconSvg {
        width: 20px;
        height: 20px;
        stroke: var(--color-warning);
      }

      .mistakes-body {
        display: flex;
        flex-direction: column;
        gap: 6px;
      }

      .mistakes-title {
        margin: 0;
        font-size: 13px;
        font-weight: 700;
        color: var(--text-color-normal);
      }

      .mistakes-list {
        display: flex;
        flex-direction: column;
        gap: 6px;
        padding-left: 16px;
        margin: 0;
        list-style: disc;
      }

      .mistakes-item {
        font-size: 12px;
        line-height: 1.5;
        color: color-mix(in srgb, var(--text-color-normal) 72%, transparent);
      }

      @media (max-width: 700px) {
        .cards {
          grid-template-columns: 1fr;
        }
      }
    </style>
  </template>
}
