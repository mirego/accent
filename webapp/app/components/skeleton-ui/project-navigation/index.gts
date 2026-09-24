import SkeletonUi from 'accent-webapp/components/skeleton-ui/index';
import repeat from 'accent-webapp/helpers/repeat';
import {Line, Block} from 'accent-webapp/components/skeleton-ui/content/index';
<template>
  <SkeletonUi class='skeleton'>
    {{#each (repeat 6)}}
      <div class='item'>
        <Block @width='16px' @height='16px' class='item-icon' />
        <Line @width='60%' />
      </div>
    {{/each}}
  </SkeletonUi>

  <style scoped>
    div.skeleton {
      display: flex;
      flex-direction: column;
      gap: 18px;
      padding: 25px 10px 0;
      min-height: 100dvh;
      background: var(--content-background);
    }
    div.skeleton:after {
      background: linear-gradient(
        180deg,
        rgba(255, 255, 255, 0) 0,
        var(--body-background) 90%
      );
    }

    .item {
      display: flex;
      align-items: center;
      gap: 10px;
    }

    .item-icon {
      border-radius: var(--border-radius);
    }
  </style>
</template>
