import SkeletonUi from 'accent-webapp/components/skeleton-ui/index';
import {Line, Block} from 'accent-webapp/components/skeleton-ui/content/index';
<template>
  <SkeletonUi class='skeleton'>
    <Line @width='120px' @height='8px' />
    <Line @width='260px' @height='20px' class='title' />

    <div class='badges'>
      <Block @width='60px' @height='18px' />
      <Block @width='80px' @height='18px' />
    </div>
  </SkeletonUi>

  <style scoped>
    .skeleton {
      display: flex;
      flex-direction: column;
      gap: 10px;
      padding: 15px 0;
    }

    .title {
      max-width: 100%;
    }

    .badges {
      display: flex;
      gap: 6px;
      margin-top: 2px;
    }
  </style>
</template>
