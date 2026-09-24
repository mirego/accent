import type {TemplateOnlyComponent} from '@ember/component/template-only';

interface ShapeArgs {
  width?: string;
  height?: string;
}

export const Line: TemplateOnlyComponent<{
  Element: HTMLSpanElement;
  Args: ShapeArgs;
}> = <template>
  <span
    class='shape line'
    style='width: {{if @width @width "100%"}}; height: {{if
      @height
      @height
      "10px"
    }}'
    ...attributes
  ></span>

  <style scoped>
    .line {
      display: block;
      height: 10px;
      border-radius: var(--border-radius);
      background: var(--content-background-border);
      animation: skeleton-pulse 1.6s ease-in-out infinite;
    }

    @media (prefers-reduced-motion: reduce) {
      .line {
        animation: none;
      }
    }

    @keyframes skeleton-pulse {
      0%,
      100% {
        opacity: 1;
      }
      50% {
        opacity: 0.55;
      }
    }
  </style>
</template>;

export const Circle: TemplateOnlyComponent<{
  Element: HTMLSpanElement;
  Args: {size?: string};
}> = <template>
  <span
    class='shape circle'
    style='width: {{if @size @size "24px"}}; height: {{if @size @size "24px"}}'
    ...attributes
  ></span>

  <style scoped>
    .circle {
      display: block;
      flex-shrink: 0;
      border-radius: 50%;
      background: var(--content-background-border);
      animation: skeleton-pulse 1.6s ease-in-out infinite;
    }

    @media (prefers-reduced-motion: reduce) {
      .circle {
        animation: none;
      }
    }

    @keyframes skeleton-pulse {
      0%,
      100% {
        opacity: 1;
      }
      50% {
        opacity: 0.55;
      }
    }
  </style>
</template>;

export const Block: TemplateOnlyComponent<{
  Element: HTMLSpanElement;
  Args: ShapeArgs;
}> = <template>
  <span
    class='shape block'
    style='width: {{if @width @width "100%"}}; height: {{if
      @height
      @height
      "40px"
    }}'
    ...attributes
  ></span>

  <style scoped>
    .block {
      display: block;
      border-radius: var(--border-radius);
      background: var(--content-background-border);
      animation: skeleton-pulse 1.6s ease-in-out infinite;
    }

    @media (prefers-reduced-motion: reduce) {
      .block {
        animation: none;
      }
    }

    @keyframes skeleton-pulse {
      0%,
      100% {
        opacity: 1;
      }
      50% {
        opacity: 0.55;
      }
    }
  </style>
</template>;
