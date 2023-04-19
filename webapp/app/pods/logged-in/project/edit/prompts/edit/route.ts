import Route from '@ember/routing/route';

export default class PromptEditRoute extends Route {
  model({promptId}: {promptId: string}) {
    return {
      projectModel: this.modelFor('logged-in.project'),
      promptsModel: this.modelFor('logged-in.project.edit.prompts'),
      promptId,
    };
  }
}
