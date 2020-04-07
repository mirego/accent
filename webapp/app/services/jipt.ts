import Service, {inject as service} from '@ember/service';
import RouterService from '@ember/routing/router-service';

export default class JIPT extends Service {
  @service('router')
  router: RouterService;

  listTranslations(translationsEntries: any, revision: any) {
    const translations = translationsEntries.reduce(
      (memo: any, translation: any) => {
        const key = `${translation.key}@${translation.document.path}`;
        memo[key] = {
          text: translation.correctedText,
          id: translation.id,
          key,
          isConflicted: translation.isConflicted,
        };
        return memo;
      },
      {}
    );

    const payload = {translations, revisionId: revision.id};

    window.parent.postMessage(
      {jipt: true, action: 'listTranslations', payload},
      '*'
    );
  }

  changeText(translationId: string, text: string) {
    const payload = {
      translationId,
      text,
    };

    window.parent.postMessage({jipt: true, action: 'changeText', payload}, '*');
  }

  updateTranslation(translationId: string, translation: any) {
    const payload = {
      translationId,
      ...translation,
    };

    window.parent.postMessage(
      {jipt: true, action: 'updateTranslation', payload},
      '*'
    );
  }

  redirectIfEmbedded() {
    window.addEventListener('message', (payload) => {
      payload.data.jipt &&
        payload.data.projectId &&
        this.router.transitionTo('logged-in.jipt', payload.data.projectId);
    });
    window.parent.postMessage({jipt: true, action: 'redirectIfEmbedded'}, '*');
  }

  login() {
    window.parent.postMessage({jipt: true, action: 'login'}, '*');
  }

  loggedIn() {
    window.parent.postMessage({jipt: true, action: 'loggedIn'}, '*');
  }
}

declare module '@ember/service' {
  interface Registry {
    jipt: JIPT;
  }
}
