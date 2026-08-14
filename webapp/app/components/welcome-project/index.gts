import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import t from 'ember-intl/helpers/t';
import {on} from '@ember/modifier';
import {LinkTo} from '@ember/routing';
import didInsert from '@ember/render-modifiers/modifiers/did-insert';
import didUpdate from '@ember/render-modifiers/modifiers/did-update';
import CodeSvg from 'accent-webapp/svgs/assets/code.svg';
import LanguageSvg from 'accent-webapp/svgs/assets/language.svg';
import SyncSvg from 'accent-webapp/svgs/assets/sync.svg';
import UsersSvg from 'accent-webapp/svgs/assets/users.svg';
import {scopedClass} from 'ember-scoped-css';

interface Args {
  project: any;
}

interface Segment {
  text: string;
  color?: 'green' | 'cyan' | 'dim' | 'link';
}

interface Line {
  id: number;
  prompt: boolean;
  segments: Segment[];
}

type Step =
  | {run: 'prompt'}
  | {run: 'wait'; ms: number}
  | {run: 'type'; text: string}
  | {run: 'print'; segments: Segment[]; delay?: number};

const out = (text: string, delay?: number): Step => ({
  run: 'print',
  segments: text ? [{text}] : [],
  delay,
});

const check = (text: string, delay?: number): Step => ({
  run: 'print',
  segments: [{text}, {text: '✓', color: 'green'}],
  delay,
});

const guideLink = (): Step => ({
  run: 'print',
  segments: [
    {text: 'For more informations on operations: '},
    {
      text: 'https://www.accent.reviews/guides/glossary.html#sync',
      color: 'link',
    },
  ],
  delay: 80,
});

const SCRIPT: Step[] = [
  {run: 'prompt'},
  {run: 'wait', ms: 900},
  {run: 'type', text: 'cat accent.json'},
  {run: 'wait', ms: 350},
  out('{', 24),
  out('  "files": [', 24),
  out('    {', 24),
  out('      "format": "json",', 24),
  out('      "source": "translations/fr.json",', 24),
  out('      "target": "translations/%slug%.json"', 24),
  out('    }', 24),
  out('  ]', 24),
  out('}', 24),
  {run: 'wait', ms: 1200},
  {run: 'prompt'},
  {run: 'type', text: 'accent sync --dry-run'},
  {run: 'wait', ms: 450},
  check('Fetch config in accent.json... API Client ', 300),
  out('', 60),
  check('Syncing sources → fr  ', 500),
  out('', 60),
  out('   translations/fr.json translations', 220),
  {
    run: 'print',
    segments: [{text: '   New : '}, {text: '1', color: 'green'}],
    delay: 60,
  },
  out('', 60),
  guideLink(),
  {
    run: 'print',
    segments: [
      {
        text: 'Syncing took 195 milliseconds, remove --dry-run to commit your changes to the server',
        color: 'dim',
      },
    ],
    delay: 60,
  },
  {run: 'wait', ms: 1600},
  {run: 'prompt'},
  {run: 'type', text: 'accent sync'},
  {run: 'wait', ms: 450},
  check('Fetch config in accent.json... API Client ', 300),
  out('', 60),
  check('Syncing sources → en  ', 500),
  out('', 60),
  {
    run: 'print',
    segments: [
      {text: '   ↑ ', color: 'cyan'},
      {text: 'translations/fr.json translations'},
    ],
    delay: 220,
  },
  out('', 60),
  out('Writing files locally', 280),
  out('', 60),
  {
    run: 'print',
    segments: [
      {text: '   ↓ ', color: 'cyan'},
      {text: 'translations/fr.json translations → fr'},
    ],
    delay: 200,
  },
  {
    run: 'print',
    segments: [
      {text: '   ↓ ', color: 'cyan'},
      {text: 'translations/en.json translations → en'},
    ],
    delay: 140,
  },
  out('', 60),
  guideLink(),
  {
    run: 'print',
    segments: [
      {text: 'Syncing took 650 milliseconds, ', color: 'dim'},
      {text: 'completed without issues', color: 'dim'},
    ],
    delay: 60,
  },
  {run: 'wait', ms: 3100},
  {run: 'prompt'},
];

export default class WelcomeProject extends Component<Args> {
  @tracked lines: Line[] = [];
  @tracked typing = false;
  @tracked paused = false;

  private lineId = 0;
  private resumeResolve: (() => void) | null = null;
  private resumePromise: Promise<void> | null = null;

  startTerminal = () => {
    void this.runLoop();
  };

  pause = () => {
    if (this.paused) return;
    this.paused = true;
    this.resumePromise = new Promise(
      (resolve) => (this.resumeResolve = resolve),
    );
  };

  resume = () => {
    this.paused = false;
    this.resumeResolve?.();
    this.resumeResolve = null;
    this.resumePromise = null;
  };

  scrollBottom = (element: Element) => {
    requestAnimationFrame(() => {
      element.scrollTop = element.scrollHeight;
    });
  };

  isLast = (index: number) => index === this.lines.length - 1;

  private get halted() {
    return this.isDestroying || this.isDestroyed;
  }

  private async runLoop() {
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
      this.playInstant();
      return;
    }

    while (!this.halted) {
      this.lines = [];
      this.lineId = 0;
      await this.play();
      if (this.halted) return;
      await this.sleep(3500);
    }
  }

  private async play() {
    for (const step of SCRIPT) {
      if (this.halted) return;

      switch (step.run) {
        case 'prompt':
          this.pushLine(true);
          break;
        case 'wait':
          await this.sleep(step.ms);
          break;
        case 'type':
          await this.type(step.text);
          break;
        case 'print':
          await this.sleep(step.delay ?? 30);
          this.pushLine(false, step.segments);
          break;
      }
    }
  }

  private playInstant() {
    for (const step of SCRIPT) {
      if (step.run === 'prompt') this.pushLine(true);
      if (step.run === 'type') this.appendText(step.text);
      if (step.run === 'print') this.pushLine(false, step.segments);
    }
  }

  private async type(text: string) {
    this.typing = true;

    for (const char of text) {
      if (this.halted) return;
      this.appendText(char);
      await this.sleep(30 + Math.random() * 60);
    }

    this.typing = false;
  }

  private pushLine(prompt: boolean, segments: Segment[] = []) {
    this.lines = [...this.lines, {id: this.lineId++, prompt, segments}];
  }

  private appendText(text: string) {
    const lines = [...this.lines];
    const last = lines[lines.length - 1];
    if (!last) return;

    const segments = last.segments.length ? [...last.segments] : [{text: ''}];
    const tail = segments[segments.length - 1];
    segments[segments.length - 1] = {...tail, text: tail.text + text};
    lines[lines.length - 1] = {...last, segments};
    this.lines = lines;
  }

  private async sleep(ms: number) {
    await new Promise((resolve) => setTimeout(resolve, ms));
    if (this.resumePromise) await this.resumePromise;
  }

  willDestroy() {
    super.willDestroy();
    this.resumeResolve?.();
  }

  <template>
    <section class='welcome-project' aria-labelledby='welcome-project-title'>
      <div class='hero'>
        <div class='hero-copy'>
          <h2 id='welcome-project-title' class='hero-title'>
            {{t 'components.welcome_project.welcome'}}
          </h2>

          <p class='hero-text'>
            {{t 'components.welcome_project.welcome_translations'}}
          </p>
        </div>

        <div
          class='terminal-window'
          aria-hidden='true'
          {{didInsert this.startTerminal}}
          {{on 'mouseenter' this.pause}}
          {{on 'mouseleave' this.resume}}
        >
          <div class='terminal-titlebar'>
            <span class='terminal-dot terminal-dot--red'></span>
            <span class='terminal-dot terminal-dot--yellow'></span>
            <span class='terminal-dot terminal-dot--green'></span>
            <span class='terminal-title'>accent — zsh — 80×24</span>

            {{#if this.paused}}
              <span class='terminal-paused'>
                <span class='terminal-paused-icon'></span>
                paused
              </span>
            {{/if}}
          </div>

          <div
            class='terminal-body'
            data-paused='{{this.paused}}'
            {{didUpdate this.scrollBottom this.lines}}
          >
            {{#each this.lines key='id' as |line index|}}
              <div class='terminal-row'>
                {{#if line.prompt}}<span class='terminal-prompt'>$</span>{{/if}}
                {{#each line.segments as |seg|}}<span
                    data-color={{seg.color}}
                  >{{seg.text}}</span>{{/each}}
                {{#if (this.isLast index)}}
                  <span
                    class='terminal-cursor'
                    data-solid='{{this.typing}}'
                  ></span>
                {{/if}}
              </div>
            {{/each}}
          </div>
        </div>
      </div>

      <div class='actions-header'>
        <h3 class='subtitle'>
          {{t 'components.welcome_project.first_step'}}:
        </h3>
      </div>

      <div
        class='links'
        aria-label={{t 'components.welcome_project.first_step'}}
      >
        <LinkTo
          @route='logged-in.project.files.new-sync'
          @model={{@project.id}}
          class='link link--featured'
        >
          <span class='link-icon-wrap'>
            <SyncSvg class={{scopedClass 'link-icon'}} />
          </span>

          <span class='link-content'>
            <span class='link-title'>
              {{t 'components.welcome_project.sync_file'}}
              <span class='link-subtitle'>
                {{t 'components.welcome_project.sync_file_text'}}
              </span>
            </span>
          </span>
        </LinkTo>

        <LinkTo
          @route='logged-in.project.manage-languages'
          @model={{@project.id}}
          class='link'
        >
          <span class='link-icon-wrap'>
            <LanguageSvg class={{scopedClass 'link-icon'}} />
          </span>

          <span class='link-content'>
            <span class='link-title'>
              {{t 'components.welcome_project.manage_languages'}}
              <span class='link-subtitle'>
                {{t 'components.welcome_project.manage_languages_text'}}
              </span>
            </span>
          </span>
        </LinkTo>

        <LinkTo
          @route='logged-in.project.collaborators'
          @model={{@project.id}}
          class='link'
        >
          <span class='link-icon-wrap'>
            <UsersSvg class={{scopedClass 'link-icon'}} />
          </span>

          <span class='link-content'>
            <span class='link-title'>
              {{t 'components.welcome_project.add_collaborator'}}
              <span class='link-subtitle'>
                {{t 'components.welcome_project.add_collaborator_text'}}
              </span>
            </span>
          </span>
        </LinkTo>

        <LinkTo
          @route='logged-in.project.edit.api-token'
          @model={{@project.id}}
          class='link'
        >
          <span class='link-icon-wrap'>
            <CodeSvg class={{scopedClass 'link-icon'}} />
          </span>

          <span class='link-content'>
            <span class='link-title'>
              {{t 'components.welcome_project.api_token'}}
              <span class='link-subtitle'>
                {{t 'components.welcome_project.api_token_text'}}
              </span>
            </span>
          </span>
        </LinkTo>
      </div>
    </section>

    <style scoped>
      .welcome-project {
        position: relative;
        max-width: 980px;
        margin: 0 30px;
        padding: 44px;
      }

      .hero {
        position: relative;
        display: grid;
        grid-template-columns: 1fr;
        gap: 38px;
        margin-bottom: 48px;
      }

      .hero-copy {
        position: relative;
        z-index: 1;
      }

      .hero-title {
        max-width: 560px;
        margin: 0 0 22px;
        line-height: 0.92;
        font-size: clamp(48px, 8vw, 92px);
        font-weight: 900;
        letter-spacing: -0.08em;
        color: var(--text-color-normal);
        text-wrap: balance;
      }

      .hero-text {
        max-width: 540px;
        font-size: clamp(17px, 2vw, 22px);
        font-weight: 500;
        line-height: 1.45;
        color: color-mix(in srgb, var(--text-color-normal) 62%, transparent);
        text-wrap: balance;
      }

      .terminal-window {
        overflow: hidden;
        width: 100%;
        max-width: 780px;
        border: 1px solid color-mix(in srgb, white 9%, transparent);
        border-radius: 10px;
        background: #1c2128;
        box-shadow:
          0 30px 60px color-mix(in srgb, black 28%, transparent),
          0 3px 10px color-mix(in srgb, black 22%, transparent);
      }

      .terminal-titlebar {
        position: relative;
        display: flex;
        align-items: center;
        gap: 8px;
        height: 36px;
        padding: 0 14px;
        border-bottom: 1px solid color-mix(in srgb, black 45%, transparent);
        background: linear-gradient(#2b313a, #232830);
      }

      .terminal-dot {
        width: 12px;
        height: 12px;
        border-radius: 50%;
      }

      .terminal-dot--red {
        background: #ff5f57;
      }

      .terminal-dot--yellow {
        background: #febc2e;
      }

      .terminal-dot--green {
        background: #28c840;
      }

      .terminal-title {
        position: absolute;
        left: 0;
        right: 0;
        font-size: 12px;
        font-weight: 500;
        color: color-mix(in srgb, white 45%, transparent);
        text-align: center;
        pointer-events: none;
      }

      .terminal-paused {
        position: relative;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        margin-left: auto;
        padding: 3px 9px;
        border-radius: 20px;
        background: color-mix(in srgb, white 10%, transparent);
        font-size: 10px;
        font-weight: 700;
        letter-spacing: 0.1em;
        color: color-mix(in srgb, white 65%, transparent);
        text-transform: uppercase;
        animation: terminal-paused-in 0.15s ease-out;
      }

      .terminal-paused-icon {
        width: 7px;
        height: 9px;
        border-left: 2.5px solid currentColor;
        border-right: 2.5px solid currentColor;
      }

      @keyframes terminal-paused-in {
        from {
          opacity: 0;
          transform: translateY(-2px);
        }

        to {
          opacity: 1;
          transform: translateY(0);
        }
      }

      .terminal-body {
        overflow: hidden;
        height: 330px;
        padding: 12px 16px;
        font-family: var(--font-monospace);
        font-size: 12.5px;
        line-height: 1.6;
        color: #d6dde6;
        cursor: text;
      }

      .terminal-row {
        display: flex;
        align-items: center;
        min-height: 1.6em;
      }

      .terminal-row span {
        white-space: pre;
      }

      .terminal-prompt {
        margin-right: 0.75ch;
        color: #3fb950;
        font-weight: 700;
      }

      .terminal-row [data-color='green'] {
        color: #3fb950;
      }

      .terminal-row [data-color='cyan'] {
        color: #39c5cf;
      }

      .terminal-row [data-color='dim'] {
        color: color-mix(in srgb, #d6dde6 48%, transparent);
      }

      .terminal-row [data-color='link'] {
        color: #58a6ff;
        text-decoration: underline;
      }

      .terminal-cursor {
        display: inline-block;
        width: 0.62em;
        height: 1.15em;
        margin-left: 2px;
        background: #d6dde6;
        animation: terminal-cursor-blink 1.1s steps(1, end) infinite;
      }

      .terminal-cursor[data-solid='true'] {
        animation: none;
      }

      .terminal-body[data-paused='true'] .terminal-cursor {
        opacity: 1;
        animation-play-state: paused;
      }

      @keyframes terminal-cursor-blink {
        0%,
        49% {
          opacity: 1;
        }

        50%,
        100% {
          opacity: 0;
        }
      }

      .actions-header {
        position: relative;
        z-index: 1;
        display: flex;
        align-items: center;
        gap: 14px;
        margin-bottom: 24px;
      }

      .actions-header:after {
        flex: 1;
        height: 1px;
        content: '';
        background: linear-gradient(
          90deg,
          color-mix(in srgb, var(--color-primary) 28%, transparent),
          transparent
        );
      }

      .subtitle {
        margin: 0;
        font-family: var(--font-monospace);
        font-size: 12px;
        font-weight: 700;
        letter-spacing: 0.08em;
        color: color-mix(in srgb, var(--text-color-normal) 72%, transparent);
        text-transform: uppercase;
      }

      .links {
        position: relative;
        z-index: 1;
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 12px;
      }

      .link {
        position: relative;
        overflow: hidden;
        display: grid;
        grid-template-columns: auto 1fr;
        gap: 10px;
        padding: 12px 8px 12px 10px;
        border-radius: var(--border-radius);
        color: var(--text-color-normal);
        text-decoration: none;
        transition: 0.18s ease-in-out;
        transition-property: border-color, box-shadow, transform, background;
      }

      .link--featured {
        background: color-mix(in srgb, var(--color-primary) 14%, transparent);
      }

      .link:focus,
      .link:hover {
        background: color-mix(in srgb, var(--color-primary) 14%, transparent);
      }

      .link-icon-wrap {
        position: relative;
        display: grid;
        place-items: center;
        width: 36px;
        height: 36px;
        color: var(--color-primary);
      }

      .link-content {
        position: relative;
        min-width: 0;
        padding-right: 18px;
      }

      .link-title {
        display: block;
        max-width: 360px;
        font-size: 17px;
        font-weight: 800;
      }

      .link-subtitle {
        display: block;
        margin-top: 3px;
        font-size: 13px;
        font-weight: 500;
        line-height: 1.45;
        letter-spacing: 0;
        color: color-mix(in srgb, var(--text-color-normal) 58%, transparent);
      }

      .link-icon {
        width: 24px;
        height: 24px;
        stroke: var(--color-primary);
      }

      @media (max-width: 880px) {
        .welcome-project {
          padding: 36px;
        }

        .hero {
          gap: 26px;
        }

        .terminal-body {
          height: 300px;
          font-size: 11px;
        }

        .links {
          grid-template-columns: repeat(2, minmax(0, 1fr));
        }
      }

      @media (max-width: 620px) {
        .welcome-project {
          margin: 0 14px;
          padding: 28px;
          border-radius: var(--border-radius);
        }

        .hero-title {
          letter-spacing: -0.06em;
        }

        .terminal-window {
          display: none;
        }

        .links {
          grid-template-columns: 1fr;
        }

        .link,
        .link--featured {
          grid-column: auto;
          min-height: 0;
        }
      }
    </style>
  </template>
}
