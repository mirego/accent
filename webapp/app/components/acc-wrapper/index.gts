<template>
  <div class='wrapper'>
    {{yield}}
  </div>

  <style scoped>
    .wrapper {
      display: flex;
      align-items: stretch;
      margin: 0 auto;
      max-width: var(--screen-lg);
      width: 100%;
      min-height: 100vh;
    }
  </style>
</template>
