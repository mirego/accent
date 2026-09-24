import SkeletonUi from 'accent-webapp/components/skeleton-ui/index';
import repeat from 'accent-webapp/helpers/repeat';
import {Line, Block} from 'accent-webapp/components/skeleton-ui/content/index';
<template>
  <SkeletonUi class='skeleton'>
    <div class='content'>
      <div class='stat'>
        <Block @width='120px' @height='80px' class='stat-number' />
        <Line @width='140px' />
      </div>

      <div class='stats'>
        <div class='actions'>
          <Block @width='80px' @height='28px' />
          <Block @width='80px' @height='28px' />
          <Block @width='80px' @height='28px' />
        </div>

        {{#each (repeat 4)}}
          <div class='revision'>
            <div class='revision-header'>
              <Line @width='120px' @height='14px' />
              <Line @width='50px' />
            </div>
            <Block @height='8px' class='revision-progress' />
          </div>
        {{/each}}
      </div>
    </div>

    <div class='activities'>
      <Line @width='120px' @height='14px' class='activities-title' />
      {{#each (repeat 5)}}
        <div class='activity'>
          <Line @width='70%' />
          <Line @width='50%' />
        </div>
      {{/each}}
    </div>
  </SkeletonUi>

  <style scoped>
    .skeleton {
      display: flex;
      flex-wrap: wrap;
      gap: 40px;
      margin-top: 40px;
    }

    .content {
      display: flex;
      flex-direction: column;
      gap: 20px;
      flex: 1 1 340px;
      min-width: 0;
    }

    .stat {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 12px;
      margin-bottom: 10px;
    }

    .stat-number {
      border-radius: var(--border-radius);
    }

    .stats {
      display: flex;
      flex-direction: column;
      gap: 20px;
      width: 100%;
    }

    .actions {
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
    }

    .revision {
      display: flex;
      flex-direction: column;
      gap: 8px;
    }

    .revision-header {
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .revision-progress {
      border-radius: var(--border-radius);
    }

    .activities {
      display: flex;
      flex-direction: column;
      gap: 16px;
      flex: 1 1 260px;
      min-width: 0;
    }

    .activities-title {
      margin-bottom: 4px;
    }

    .activity {
      display: flex;
      flex-direction: column;
      gap: 6px;
    }
  </style>
</template>
