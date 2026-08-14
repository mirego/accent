import {LinkTo} from '@ember/routing';
import t from 'ember-intl/helpers/t';
<template>
  <LinkTo
    @route='logged-in.project.edit.index'
    class='button button--borderless button--primary local-button'
  >
    {{t 'components.project_settings.back_link.title'}}
  </LinkTo>

  <style scoped>
    a.local-button {
      margin-left: -5px;
      padding-left: 5px;
      padding-right: 5px;
    }

    @media (max-width: 640px) {
      a.local-button {
        margin-top: 20px;
      }
    }
  </style>
</template>
