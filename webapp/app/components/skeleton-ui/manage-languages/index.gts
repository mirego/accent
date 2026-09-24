import SkeletonUi from 'accent-webapp/components/skeleton-ui/index';
import repeat from 'accent-webapp/helpers/repeat';
import {Line, Block} from 'accent-webapp/components/skeleton-ui/content/index';
<template>
  <SkeletonUi class='skeleton'>
    <div class='overview'>
      {{#each (repeat 5)}}
        <div class='revision'>
          <div class='revision-header'>
            <Line @width='120px' @height='14px' />
            <Line @width='50px' />
          </div>
          <div class='revision-infos'>
            <Line @width='90px' @height='8px' />
            <Block @width='90px' @height='8px' class='revision-progress' />
          </div>
        </div>
      {{/each}}

      <Block @height='40px' class='createForm' />
    </div>

    <div class='help'>
      {{#each (repeat 3)}}
        <div class='helpItem'>
          <Block @width='36px' @height='36px' class='helpItem-icon' />
          <div class='helpItem-body'>
            <Line @width='140px' @height='12px' />
            <Line @width='100%' />
            <Line @width='80%' />
          </div>
        </div>
      {{/each}}
    </div>
  </SkeletonUi>

  <style scoped>
    .skeleton {
      display: flex;
      flex-wrap: wrap;
      gap: 40px;
      margin-top: 30px;
    }

    .overview {
      display: flex;
      flex-direction: column;
      gap: 20px;
      flex: 1 1 340px;
      min-width: 0;
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

    .revision-infos {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 10px;
    }

    .revision-progress {
      border-radius: var(--border-radius);
    }

    .createForm {
      margin-top: 10px;
      border-radius: var(--border-radius);
    }

    .help {
      display: flex;
      flex-direction: column;
      gap: 20px;
      flex: 1 1 260px;
      min-width: 0;
    }

    .helpItem {
      display: flex;
      align-items: flex-start;
      gap: 12px;
    }

    .helpItem-icon {
      border-radius: var(--border-radius);
    }

    .helpItem-body {
      display: flex;
      flex-direction: column;
      gap: 6px;
      flex: 1 1 auto;
      min-width: 0;
    }
  </style>
</template>
