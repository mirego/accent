import EmberRouter from '@ember/routing/router';
import config from './config/environment';

const Router = EmberRouter.extend({
  location: config.locationType,
  rootURL: config.rootURL
});

export default Router.map(function() {
  this.route('login', {path: ''});

  this.route('logged-in', {path: 'app'}, function() {
    this.route('projects', function() {
      this.route('new');
    });

    this.route('project', {path: 'projects/:projectId'}, function() {
      this.route('edit', function() {
        this.route('badges');
        this.route('api-token');
        this.route('collaborators');
        this.route('service-integrations');
        this.route('manage-languages');
      });

      this.route('activity', {path: 'activities/:activityId'});
      this.route('activities');
      this.route('files', function() {
        this.route('new-sync');
        this.route('sync', {path: ':fileId/sync'});
        this.route('add-translations', {path: ':fileId/add-translations'});
        this.route('export', {path: ':fileId/export'});
      });
      this.route('versions', function() {
        this.route('new');
        this.route('edit', {path: ':versionId/edit'});
        this.route('export', {path: ':versionId/export'});
      });
      this.route('comments', {path: 'conversation'});

      this.route('revision', {path: 'revisions/:revisionId'}, function() {
        this.route('translations');
        this.route('conflicts');
      });

      this.route('translation', {path: 'translations/:translationId'}, function() {
        this.route('activities');
        this.route('related-translations');
        this.route('comments', {path: 'conversation'});
      });
    });
  });

  this.route('not-found', {path: '/*path'});
});
