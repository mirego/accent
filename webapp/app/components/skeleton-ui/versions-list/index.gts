import SkeletonUi from 'accent-webapp/components/skeleton-ui/index';
import repeat from 'accent-webapp/helpers/repeat';
import Content from 'accent-webapp/components/skeleton-ui/content/index';
<template>
  <SkeletonUi class='skeleton'>
    {{#each (repeat 6)}}
      <Content @height='35' @width='400'>
        <rect x='0' y='0' rx='1' ry='1' width='28' height='4'></rect>
        <rect x='0' y='8' rx='1' ry='1' width='70' height='1'></rect>

        <rect x='0' y='13' rx='2' ry='2' width='30' height='10'></rect>
        <rect x='36' y='13' rx='2' ry='2' width='37' height='10'></rect>
      </Content>
    {{/each}}
  </SkeletonUi>

  <style scoped>
    .skeleton {
      padding: 15px 0;
    }
  </style>
</template>
