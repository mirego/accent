import SkeletonUi from 'accent-webapp/components/skeleton-ui/index';
import repeat from 'accent-webapp/helpers/repeat';
import Content from 'accent-webapp/components/skeleton-ui/content/index';
<template>
  <SkeletonUi class='skeleton'>
    {{#each (repeat 6)}}
      <Content @height='35' @width='400'>
        <rect x='0' y='0' rx='0' ry='0' width='104' height='2'></rect>
        <rect x='0' y='4' rx='0' ry='0' width='155' height='2'></rect>
        <rect x='0' y='17' rx='0' ry='0' width='217' height='1'></rect>
        <rect x='0' y='20' rx='0' ry='0' width='200' height='1'></rect>
      </Content>
    {{/each}}
  </SkeletonUi>

  <style scoped>
    .skeleton {
      margin-top: 20px;
      padding: 15px;
    }
  </style>
</template>
