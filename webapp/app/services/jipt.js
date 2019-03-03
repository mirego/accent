import Service, {inject as service} from '@ember/service';

export default Service.extend({
  router: service('router'),

  listTranslations(translationsEntries, revision) {
    const translations = translationsEntries.reduce((memo, translation) => {
      const key = `${translation.key}@${translation.document.path}`;
      memo[key] = {text: translation.correctedText, id: translation.id, key};
      return memo;
    }, {});

    const payload = {translations, revisionId: revision.id};

    window.parent.postMessage({jipt: true, action: 'listTranslations', payload}, '*');
  },

  changeText(translationId, text) {
    const payload = {
      translationId,
      text
    };

    window.parent.postMessage({jipt: true, action: 'changeText', payload}, '*');
  },

  redirectIfEmbedded() {
    window.addEventListener('message', payload => {
      payload.data.jipt && payload.data.projectId && this.router.transitionTo('logged-in.jipt', payload.data.projectId);
    });
    window.parent.postMessage({jipt: true, action: 'redirectIfEmbedded'}, '*');
  },

  login() {
    window.parent.postMessage({jipt: true, action: 'login'}, '*');
  },

  loggedIn() {
    window.parent.postMessage({jipt: true, action: 'loggedIn'}, '*');
  }
});
