import {service} from '@ember/service';
import {action} from '@ember/object';
import Controller from '@ember/controller';
import RouterService from '@ember/routing/router-service';

import projectCreateQuery, {
  CreateProjectVariables,
  CreateProjectResponse
} from 'accent-webapp/queries/create-project';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import Session from 'accent-webapp/services/session';
import {tracked} from '@glimmer/tracking';

export default class ProjectsNewController extends Controller {
  @service('apollo-mutate')
  declare apolloMutate: ApolloMutate;

  @service('session')
  declare session: Session;

  @service('router')
  declare router: RouterService;

  @tracked
  error = false;

  @action
  closeModal() {
    this.router.transitionTo('logged-in.projects');
  }

  @action
  async create(projectAttributes: CreateProjectVariables) {
    this.error = false;

    const name = projectAttributes.name || '';

    const response: CreateProjectResponse['createProject'] =
      await this.apolloMutate.mutate({
        mutation: projectCreateQuery,
        variables: {
          ...projectAttributes,
          name
        }
      });

    if (response.errors) {
      this.error = true;
    } else {
      this.router.transitionTo('logged-in.project', response.project.id);
    }

    return response;
  }
}
