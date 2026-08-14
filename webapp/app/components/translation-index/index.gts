<template>
  <div class='wrapper'>
    {{yield}}
  </div>

  <style scoped>
    .wrapper {
      display: flex;
      margin-top: 10px;
    }
    .wrapper:global(> div:first-of-type) {
      margin-right: 40px;
      width: 55%;
    }
    .wrapper:global(> div:last-of-type) {
      margin-right: 0;
      width: 45%;
    }
    .wrapper:global(> div:first-of-type:last-of-type) {
      width: 100%;
    }

    @media (max-width: 800px) {
      .wrapper {
        flex-direction: column;
      }
      .wrapper:global(> div:first-of-type:last-of-type) {
        margin-top: 0;
      }
      .wrapper:global(> div:last-of-type) {
        margin-top: 30px;
      }
      .wrapper:global(> div),
      .wrapper:global(> div:last-of-type),
      .wrapper:global(> div:first-of-type) {
        width: 100%;
      }
    }
  </style>
</template>
