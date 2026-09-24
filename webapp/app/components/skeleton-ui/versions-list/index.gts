import SkeletonUi from 'accent-webapp/components/skeleton-ui/index';
import repeat from 'accent-webapp/helpers/repeat';
import {Line, Block} from 'accent-webapp/components/skeleton-ui/content/index';
<template>
  <SkeletonUi class='skeleton'>
    <ul class='list'>
      {{#each (repeat 6)}}
        <li class='item'>
          <div class='item-info'>
            <div class='item-title'>
              <Line @width='120px' @height='14px' />
              <Line @width='50px' />
            </div>
            <Line @width='40%' @height='8px' />
          </div>

          <div class='item-actions'>
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
      margin: 0 0 16px;
      padding: 8px 0;
    }

    .item-info {
      display: flex;
      flex-direction: column;
      gap: 8px;
      flex: 1 1 240px;
      min-width: 0;
    }

    .item-title {
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .item-actions {
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
    }
  </style>
</template>
