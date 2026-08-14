import SkeletonUi from 'accent-webapp/components/skeleton-ui/index';
import repeat from 'accent-webapp/helpers/repeat';
import Content from 'accent-webapp/components/skeleton-ui/content/index';
<template>
  <SkeletonUi class='skeleton'>
    {{#each (repeat 3)}}
      <Content @height='35' @width='400'>
        <circle cx='4' cy='14' r='4'></circle>
        <rect x='12' y='14' rx='3' ry='3' width='110' height='2'></rect>
        <rect x='0' y='22' rx='3' ry='3' width='200' height='2'></rect>
        <rect x='0' y='26' rx='3' ry='3' width='230' height='2'></rect>
      </Content>
    {{/each}}
  </SkeletonUi>

  <style scoped>
    .skeleton {
      margin-top: 30px;
    }
  </style>
</template>
