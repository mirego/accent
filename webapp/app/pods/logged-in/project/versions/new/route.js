import Route from '@ember/routing/route';

export default Route.extend({
  model() {
    return this.modelFor('logged-in.project');
  },

  resetController(controller, isExiting) {
    if (isExiting) {
      controller.setProperties({
        error: false
      });
    }
  }
});
