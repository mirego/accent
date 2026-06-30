import SkeletonUi from 'accent-webapp/components/skeleton-ui/index';
import Content from 'accent-webapp/components/skeleton-ui/content/index';
<template>
  <SkeletonUi class='skeleton'>
    <Content @height='15' @width='80'>
      <rect x='0' y='0' rx='2' ry='2' width='8' height='8'></rect>
      <rect x='13' y='3' rx='1' ry='1' width='50' height='2'></rect>
    </Content>
    <Content @height='15' @width='80'>
      <rect x='0' y='0' rx='2' ry='2' width='8' height='8'></rect>
      <rect x='13' y='3' rx='1' ry='1' width='42' height='2'></rect>
    </Content>
    <Content @height='15' @width='80'>
      <rect x='0' y='0' rx='2' ry='2' width='8' height='8'></rect>
      <rect x='13' y='3' rx='1' ry='1' width='38' height='2'></rect>
    </Content>
    <Content @height='15' @width='80'>
      <rect x='0' y='0' rx='2' ry='2' width='8' height='8'></rect>
      <rect x='13' y='3' rx='1' ry='1' width='47' height='2'></rect>
    </Content>
    <Content @height='15' @width='80'>
      <rect x='0' y='0' rx='2' ry='2' width='8' height='8'></rect>
      <rect x='13' y='3' rx='1' ry='1' width='41' height='2'></rect>
    </Content>
  </SkeletonUi>
</template>
