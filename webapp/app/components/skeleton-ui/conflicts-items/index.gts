import SkeletonUi from 'accent-webapp/components/skeleton-ui/index';
import repeat from 'accent-webapp/helpers/repeat';
import {Line, Block} from 'accent-webapp/components/skeleton-ui/content/index';
<template>
  <SkeletonUi class='skeleton'>
    <ul class='list'>
      {{#each (repeat 6)}}
        <li class='item'>
          <Line @width='40%' />
          <Block @height='60px' />
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
      gap: 10px;
      margin: 0 0 20px;
    }
  </style>
</template>
