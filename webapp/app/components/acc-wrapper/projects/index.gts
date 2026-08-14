import ApplicationFooter from 'accent-webapp/components/application-footer/index';
import MiregoSvg from 'accent-webapp/svgs/assets/mirego.svg';
<template>
  <div class='content'>
    {{yield}}

    <div class='footer'>
      <ApplicationFooter />
    </div>
  </div>

  <a href='https://www.mirego.com' class='mirego'>
    <MiregoSvg />
  </a>

  <style scoped>
    .content {
      width: 100%;
      max-width: 1200px;
      margin: 40px auto;
      border-radius: var(--border-radius);
      border: 1px solid var(--content-background-border);
      overflow: hidden;
      background: var(--content-background);
    }

    .footer {
      padding: 0 20px 10px;
    }

    .mirego {
      display: flex;
      justify-content: flex-end;
      padding: 20px;
      opacity: 0.1;
      transition: 0.2s ease-in-out;
      transition-property: opacity;
    }
    .mirego:focus,
    .mirego:hover {
      opacity: 0.6;
    }

    .mirego :global(svg) {
      width: 70px;
      fill: var(--text-color-normal);
    }

    @media (max-width: 800px) {
      .content {
        margin-top: 0;
      }
    }
  </style>
</template>
