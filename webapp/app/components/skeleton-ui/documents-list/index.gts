import SkeletonUi from 'accent-webapp/components/skeleton-ui/index';
import repeat from 'accent-webapp/helpers/repeat';
import {Line, Block} from 'accent-webapp/components/skeleton-ui/content/index';
<template>
  <SkeletonUi class='skeleton'>
    <ul class='list'>
      {{#each (repeat 6)}}
        <li class='item'>
          <div class='item-info'>
            <Line @width='45%' @height='14px' />

            <div class='item-stats'>
              <Line @width='40px' @height='16px' />
              <Line @width='70px' />
            </div>

            <Block @height='6px' class='item-progress' />
          </div>

          <div class='item-actions'>
            <Block @width='70px' @height='28px' />
            <Block @width='70px' @height='28px' />
            <Block @width='70px' @height='28px' />
          </div>
        </li>
      {{/each}}
    </ul>
  </SkeletonUi>

  <style scoped>
    .skeleton {
      padding: 15px 0;
    }

    .item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      flex-wrap: wrap;
      gap: 15px;
      margin: 0 0 18px;
      padding: 10px 0;
    }

    .item-info {
      display: flex;
      flex-direction: column;
      gap: 8px;
      flex: 1 1 260px;
      min-width: 0;
    }

    .item-stats {
      display: flex;
      align-items: center;
      justify-content: space-between;
    }

    .item-progress {
      border-radius: var(--border-radius);
    }

    .item-actions {
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
    }
  </style>
</template>
