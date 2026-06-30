import t from 'ember-intl/helpers/t';
<template>
  <div class='google-login-form'>
    <a href='#' class='button button--filled googleLoginButton'>
      <img src='assets/google-logo.png' class='googleLogo' />

      {{t 'components.google_login_form.login_button'}}
    </a>
  </div>
</template>
