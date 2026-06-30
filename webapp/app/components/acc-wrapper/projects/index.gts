import ApplicationFooter from 'accent-webapp/components/application-footer/index';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
<template>
  <div class='content'>
    {{yield}}

    <div class='footer'>
      <ApplicationFooter />
    </div>
  </div>

  <a href='https://www.mirego.com' class='mirego'>
    {{inlineSvg 'assets/mirego.svg'}}
  </a>
</template>
