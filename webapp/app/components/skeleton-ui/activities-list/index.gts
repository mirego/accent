import SkeletonUi from 'accent-webapp/components/skeleton-ui/index';
import repeat from 'accent-webapp/helpers/repeat';
import Content from 'accent-webapp/components/skeleton-ui/content/index';
<template>
  <SkeletonUi class='skeleton'>
    {{#each (repeat 6)}}
      <Content @height='35' @width='400'>
        <rect x='14' y='3' rx='3' ry='3' width='88' height='2'></rect>
        <rect x='14' y='10' rx='3' ry='3' width='310' height='2'></rect>
        <rect x='14' y='14' rx='3' ry='3' width='300' height='2'></rect>
        <circle cx='6' cy='6' r='4'></circle>
        <rect x='372' y='3' rx='3' ry='3' width='28' height='2'></rect>
      </Content>
    {{/each}}
  </SkeletonUi>

  <style scoped>
    .skeleton {
      margin-top: 20px;
      padding: 15px 0;
    }
  </style>
</template>
