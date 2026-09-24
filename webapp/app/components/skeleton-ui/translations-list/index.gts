import SkeletonUi from 'accent-webapp/components/skeleton-ui/index';
import repeat from 'accent-webapp/helpers/repeat';
import {Line} from 'accent-webapp/components/skeleton-ui/content/index';
<template>
  <SkeletonUi class='skeleton'>
    <ul class='list'>
      {{#each (repeat 6)}}
        <li class='item'>
          <div class='item-header'>
            <div class='item-key'>
              <Line @width='45%' />
              <Line @width='30%' @height='8px' />
            </div>
            <Line @width='90px' class='item-meta' />
          </div>
          <Line @width='70%' />
        </li>
      {{/each}}
    </ul>
  </SkeletonUi>

  <style scoped>
    .skeleton {
      margin-top: 20px;
      padding: 15px;
    }

    .item {
      display: flex;
      flex-direction: column;
      gap: 8px;
      margin: 0 0 18px;
      padding: 4px 0;
    }

    .item-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      gap: 10px;
    }

    .item-key {
      display: flex;
      flex-direction: column;
      gap: 5px;
      flex: 1 1 auto;
      min-width: 0;
    }

    .item-meta {
      flex-shrink: 0;
    }
  </style>
</template>
