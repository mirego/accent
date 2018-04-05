import Component from '@ember/component';

// Attributes
// revisionOperation: Object containing the <language> and array of <operation>
export default Component.extend({
  showStats: true,
  showOperations: false,
  hideDetails: false,

  actions: {
    showStats() {
      this.setProperties({
        showStats: true,
        showOperations: false,
        hideDetails: false
      });
    },

    showOperations() {
      this.setProperties({
        showStats: false,
        showOperations: true,
        hideDetails: false
      });
    },

    hideDetails() {
      this.setProperties({
        showStats: false,
        showOperations: false,
        hideDetails: true
      });
    }
  }
});
