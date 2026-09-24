import SkeletonUi from 'accent-webapp/components/skeleton-ui/index';
import repeat from 'accent-webapp/helpers/repeat';
import {
  Line,
  Block,
  Circle
} from 'accent-webapp/components/skeleton-ui/content/index';
<template>
  <SkeletonUi class='skeleton'>
    <div class='columns'>
      <div class='columns-item'>
        <Block @height='40px' class='createForm' />

        <ul class='list'>
          {{#each (repeat 5)}}
            <li class='collaborator'>
              <Circle @size='28px' />
              <div class='collaborator-body'>
                <Line @width='160px' />
                <Line @width='120px' @height='8px' />
              </div>
              <Line @width='70px' class='collaborator-role' />
            </li>
          {{/each}}
        </ul>
      </div>

      <div class='columns-item roles'>
        <Line @width='90px' @height='8px' class='roles-heading' />
        {{#each (repeat 5)}}
          <div class='role'>
            <Block @width='32px' @height='32px' class='role-icon' />
            <div class='role-body'>
              <Line @width='90px' />
              <Line @width='100%' />
              <Line @width='75%' />
            </div>
          </div>
        {{/each}}
      </div>
    </div>
  </SkeletonUi>

  <style scoped>
    .skeleton {
      margin-top: 30px;
    }

    .columns {
      display: flex;
      align-items: flex-start;
      gap: 25px;
      margin-top: 20px;
    }

    .columns-item:first-of-type {
      flex: 1 0 60%;
      min-width: 0;
    }
    .columns-item:last-of-type {
      flex: 1 1 100%;
      min-width: 0;
    }

    .createForm {
      margin-bottom: 20px;
      border-radius: var(--border-radius);
    }

    .list {
      display: flex;
      flex-direction: column;
      gap: 16px;
    }

    .collaborator {
      display: flex;
      align-items: center;
      gap: 10px;
    }

    .collaborator-body {
      display: flex;
      flex-direction: column;
      gap: 5px;
      flex: 1 1 auto;
      min-width: 0;
    }

    .collaborator-role {
      flex-shrink: 0;
    }

    .roles {
      display: flex;
      flex-direction: column;
      gap: 16px;
    }

    .roles-heading {
      margin-bottom: 4px;
    }

    .role {
      display: flex;
      align-items: flex-start;
      gap: 12px;
    }

    .role-icon {
      border-radius: var(--border-radius);
    }

    .role-body {
      display: flex;
      flex-direction: column;
      gap: 5px;
      flex: 1 1 auto;
      min-width: 0;
    }
  </style>
</template>
