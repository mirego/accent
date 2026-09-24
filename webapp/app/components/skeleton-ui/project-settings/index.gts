import SkeletonUi from 'accent-webapp/components/skeleton-ui/index';
import repeat from 'accent-webapp/helpers/repeat';
import {
  Line,
  Block,
  Circle
} from 'accent-webapp/components/skeleton-ui/content/index';
<template>
  <SkeletonUi class='skeleton'>
    <div class='form'>
      <div class='field'>
        <Line @width='80px' @height='8px' />
        <Block @height='36px' />
      </div>

      <div class='fields'>
        <div class='field'>
          <Line @width='70px' @height='8px' />
          <Block @width='60px' @height='36px' />
        </div>
        <div class='field'>
          <Line @width='60px' @height='8px' />
          <Circle @size='36px' />
        </div>
      </div>

      <Block @width='120px' @height='32px' />
    </div>

    {{#each (repeat 3)}}
      <div class='section'>
        <Line @width='160px' @height='12px' />
        <Line @width='100%' />
        <Line @width='70%' />
      </div>
    {{/each}}
  </SkeletonUi>

  <style scoped>
    .skeleton {
      display: flex;
      flex-direction: column;
      gap: 30px;
      margin-top: 20px;
      max-width: 640px;
    }

    .form {
      display: flex;
      flex-direction: column;
      gap: 18px;
    }

    .field {
      display: flex;
      flex-direction: column;
      gap: 8px;
    }

    .fields {
      display: flex;
      gap: 20px;
    }

    .section {
      display: flex;
      flex-direction: column;
      gap: 8px;
      padding-top: 20px;
      border-top: 1px solid var(--content-background-border);
    }
  </style>
</template>
