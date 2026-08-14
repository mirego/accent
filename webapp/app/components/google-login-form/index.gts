import t from 'ember-intl/helpers/t';
<template>
  <div class='google-login-form'>
    <a href='#' class='button button--filled googleLoginButton'>
      <img src='assets/google-logo.png' class='googleLogo' />

      {{t 'components.google_login_form.login_button'}}
    </a>
  </div>

  <style scoped>
    .google-login-form {
      max-width: 500px;
      margin: 0 auto 30px;
      text-align: center;
    }

    .googleLogo {
      width: 30px;
      margin-right: 10px;
    }

    .googleLoginButton {
      opacity: 1;
      margin-top: 10px;
      padding: 7px 40px 7px 20px;
      background: #4d90fe;
      border: 1px solid rgb(51.6424581006, 128.187150838, 253.8575418994);
      font-family: arial, sans-serif;
      font-size: 14px;
    }
    .googleLoginButton:focus,
    .googleLoginButton:hover {
      background: rgb(36.4279329609, 118.6994413408, 253.7720670391);
    }

    @media (max-width: 440px) {
      .google-login-form {
        margin-top: 30px;
      }
    }
  </style>
</template>
