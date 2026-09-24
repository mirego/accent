import SkeletonUi from 'accent-webapp/components/skeleton-ui/index';
import repeat from 'accent-webapp/helpers/repeat';
import {Line, Circle} from 'accent-webapp/components/skeleton-ui/content/index';
<template>
  <SkeletonUi class='skeleton'>
    <div class='list'>
      {{#each (repeat 3)}}
        <div class='comment'>
          <div class='comment-header'>
            <Circle @size='18px' />
            <Line @width='110px' />
            <Line @width='60px' @height='8px' class='comment-date' />
          </div>
          <Line @width='85%' />
          <Line @width='60%' />
        </div>
      {{/each}}
    </div>
  </SkeletonUi>

  <style scoped>
    .skeleton {
      margin-top: 30px;
    }

    .list {
      display: flex;
      flex-direction: column;
      background: var(--background-light);
      border-radius: var(--border-radius);
    }

    .comment {
      display: flex;
      flex-direction: column;
      gap: 6px;
      padding: 10px;
      border-bottom: 1px solid var(--content-background-border);
    }
    .comment:last-of-type {
      border-bottom: 0;
    }

    .comment-header {
      display: flex;
      align-items: center;
      gap: 8px;
      margin-bottom: 2px;
    }

    .comment-date {
      margin-left: auto;
    }
  </style>
</template>
