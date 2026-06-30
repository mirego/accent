import {LinkTo} from '@ember/routing';
import t from 'ember-intl/helpers/t';
<template>
  <LinkTo
    @route='logged-in.project.edit.index'
    class='button button--borderless button--primary local-button'
  >
    {{t 'components.project_settings.back_link.title'}}
  </LinkTo>
</template>
