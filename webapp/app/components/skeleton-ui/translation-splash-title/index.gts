import SkeletonUi from 'accent-webapp/components/skeleton-ui/index';
import Content from 'accent-webapp/components/skeleton-ui/content/index';
<template>
  <SkeletonUi class='skeleton'>
    <Content @height='35' @width='400'>
      <rect x='0' y='0' rx='1' ry='1' width='28' height='2'></rect>
      <rect x='0' y='10' rx='1' ry='1' width='50' height='1'></rect>
      <rect x='0' y='18' rx='1' ry='1' width='70' height='4'></rect>
    </Content>
  </SkeletonUi>
</template>
