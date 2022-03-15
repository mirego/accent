import fmt from 'simple-fmt';
import Service, {inject as service} from '@ember/service';
import config from 'accent-webapp/config/environment';
import AuthenticatedRequest from 'accent-webapp/services/authenticated-request';

interface TranslateFileOptions {
  project: any;
  file: File;
  toLanguage: string;
  fromLanguage: string;
  documentFormat: string;
}

interface TranslateDocumentOptions {
  project: any;
  documentId: string;
  toLanguage: string;
  fromLanguage: string;
  documentFormat: string;
}

export default class MachineTranslations extends Service {
  @service('authenticated-request')
  authenticatedRequest: AuthenticatedRequest;

  async translateDocument({
    project,
    documentId,
    toLanguage,
    fromLanguage,
    documentFormat,
  }: TranslateDocumentOptions) {
    const url = fmt(
      config.API.MACHINE_TRANSLATIONS_TRANSLATE_DOCUMENT_PROJECT_PATH,
      project.id,
      fromLanguage,
      toLanguage,
      documentId,
      documentFormat
    );

    return this.authenticatedRequest.post(url);
  }

  async translateFile({
    project,
    file,
    toLanguage,
    fromLanguage,
    documentFormat,
  }: TranslateFileOptions) {
    const url = fmt(
      config.API.MACHINE_TRANSLATIONS_TRANSLATE_FILE_PROJECT_PATH,
      project.id,
      fromLanguage,
      toLanguage,
      documentFormat
    );

    return this.authenticatedRequest.machineTranslationsTranslateFile(url, {
      file,
    });
  }
}

declare module '@ember/service' {
  interface Registry {
    'machine-translations': MachineTranslations;
  }
}
