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

    create({languageId, name}) {
      this.set('error', false);
      name = name || '';

      return this.apolloMutate
        .mutate({
          mutation: projectCreateQuery,
          variables: {
            name,
            languageId
          }
        })
        .then(createProject => this.transitionToRoute('logged-in.project', createProject.project.id))
        .catch(() => this.set('error', true));
    }
  }
});
