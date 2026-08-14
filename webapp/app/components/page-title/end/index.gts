<template>
  <div class='wrapper'>
    {{yield}}
  </div>

  <style scoped>
    .wrapper {
      position: absolute;
      top: 6px;
      right: 0;
      display: flex;
      gap: 10px;
    }
  </style>
</template>
