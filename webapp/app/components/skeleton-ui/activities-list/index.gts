import SkeletonUi from 'accent-webapp/components/skeleton-ui/index';
import repeat from 'accent-webapp/helpers/repeat';
import {Line, Circle} from 'accent-webapp/components/skeleton-ui/content/index';
<template>
  <SkeletonUi class='skeleton'>
    <ul class='list'>
      {{#each (repeat 6)}}
        <li class='item'>
          <Circle @size='21px' class='item-icon' />

          <div class='item-content'>
            <div class='item-header'>
              <Line @width='140px' />
              <Line @width='60px' class='item-date' />
            </div>
            <Line @width='80%' />
            <Line @width='55%' />
          </div>
        </li>
      {{/each}}
    </ul>
  </SkeletonUi>

  <style scoped>
    .skeleton {
      margin-top: 20px;
      padding: 15px 0;
    }

    .list {
      position: relative;
    }
    .list:before {
      content: '';
      position: absolute;
      top: 0;
      left: 10px;
      width: 1px;
      height: 100%;
      background: var(--content-background-border);
    }

    .item {
      display: flex;
      gap: 12px;
      margin: 0 0 25px;
    }

    .item-icon {
      position: relative;
      z-index: 1;
      box-shadow: 0 0 0 5px var(--content-background);
    }

    .item-content {
      display: flex;
      flex-direction: column;
      gap: 6px;
      flex: 1 1 auto;
      min-width: 0;
    }

    .item-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: 10px;
      margin-bottom: 4px;
    }

    .item-date {
      flex-shrink: 0;
    }
  </style>
</template>
