import EmberRouter from '@ember/routing/router';
import config from './config/environment';

class Router extends EmberRouter {
  location = config.locationType;
  rootURL = config.rootURL;
}

/* eslint-disable max-nested-callbacks */
export default Router.map(function () {
  this.route('login', {path: ''});

  this.route('logged-in', {path: 'app'}, function () {
    this.route('jipt', {path: 'projects/:projectId/jipt'}, function () {
      this.route(
        'translation',
        {path: 'translations/:translationId'},
        function () {
          this.route('index');
        }
      );
    });

    this.route('projects', function () {
      this.route('new');
    });

    this.route('project', {path: 'projects/:projectId'}, function () {
      this.route('edit', function () {
        this.route('badges');
        this.route('api-token');
        this.route('service-integrations');
        this.route('jipt');
        this.route('machine-translations');
        this.route('prompts', function () {
          this.route('new');
          this.route('edit', {path: '/:promptId'});
        });
      });

      this.route('collaborators');
      this.route('manage-languages', function () {
        this.route('edit', {path: '/:revisionId'});
      });

      this.route('activity', {path: 'activities/:activityId'});
      this.route('activities');
      this.route('files', function () {
        this.route('export-all');
        this.route('new-sync');
        this.route('new-machine-translations');
        this.route('sync', {path: ':fileId/sync'});
        this.route('add-translations', {path: ':fileId/add-translations'});
        this.route('export', {path: ':fileId/export'});
        this.route('jipt', {path: ':fileId/jipt'});
        this.route('machine-translations', {
          path: ':fileId/machine-translations',
        });
      });
      this.route('versions', function () {
        this.route('new');
        this.route('edit', {path: ':versionId/edit'});
        this.route('export', {path: ':versionId/export'});
      });
      this.route('comments', {path: 'conversation'});

      this.route('revision', {path: 'revisions/:revisionId'}, function () {
        this.route('translations');
        this.route('conflicts');
        this.route('lint-translations');
      });

      this.route(
        'translation',
        {path: 'translations/:translationId'},
        function () {
          this.route('activities');
          this.route('related-translations');
          this.route('editions');
          this.route('comments', {path: 'conversation'});
        }
      );
    });
  });

  this.route('not-found', {path: '/*path'});
});
