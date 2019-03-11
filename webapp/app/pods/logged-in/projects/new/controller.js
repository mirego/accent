import {inject as service} from '@ember/service';
import Controller from '@ember/controller';

import projectCreateQuery from 'accent-webapp/queries/create-project';

export default Controller.extend({
  apolloMutate: service('apollo-mutate'),
  session: service(),

  error: false,

  actions: {
    closeModal() {
      this.transitionToRoute('logged-in.projects');
    },

    create(projectAttributes) {
      this.set('error', false);
      name = projectAttributes.name || '';

      return this.apolloMutate
        .mutate({
          mutation: projectCreateQuery,
          variables: {
            name,
            ...projectAttributes
          }
        })
        .then(createProject =>
          this.transitionToRoute('logged-in.project', createProject.project.id)
        )
        .catch(() => this.set('error', true));
    }
  }
});
