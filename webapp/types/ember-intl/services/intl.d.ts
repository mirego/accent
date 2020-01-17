import IntlService from 'ember-intl/services/intl';

declare module 'ember-intl/services/intl' {
  export default class IntlService {
    primaryLocale: string;
    locales: string[];
    t(
      translationKey: string,
      optionalOptions?: object,
      optionalFormats?: object
    ): string;
    exists(translationKey: string, localeName: string): boolean;
    setLocale(localeName: string): void;
    addTranslations(localeName: string, translations: object): object;
    formatRelative(dateString: string): string;
  }
}

declare module '@ember/service' {
  interface Registry {
    intl: IntlService;
  }
}
