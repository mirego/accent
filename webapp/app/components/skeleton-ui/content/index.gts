import Component from '@glimmer/component';

interface Args {
  height: string;
  width: string;
}

export default class SkeletonUiContent extends Component<Args> {
  <template>
    <svg
      role='img'
      width={{@width}}
      height={{@height}}
      viewBox={{this.viewBox}}
      preserveAspectRatio='none'
      ...attributes
    >
      <rect width={{@width}} height={{@height}} fill={{this.primaryColor}} />
      <g fill={{this.secondaryColor}}>
        {{yield}}
      </g>
    </svg>
  </template>
  get viewBox() {
    return `0 0 ${this.args.width} ${this.args.height}`;
  }

  get primaryColor() {
    return 'var(--content-background)';
  }

  get secondaryColor() {
    return 'var(--content-background-border)';
  }
}
