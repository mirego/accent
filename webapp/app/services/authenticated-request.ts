import Service, {service} from '@ember/service';
import fetch from 'fetch';
import Session from 'accent-webapp/services/session';

const HTTP_ERROR_STATUS = 400;

interface CommitOptions {
  file: File;
  documentPath: string;
  documentFormat: string;
  version?: string;
  syncType?: string;
}

interface PeekOptions {
  file: File;
  documentPath: string;
  version?: string;
  documentFormat: string;
}

interface MachineTranslationsTranslateFileOptions {
  file: File;
  documentPath?: string;
  documentFormat?: string;
}

export default class AuthenticatedRequest extends Service {
  @service('session')
  declare session: Session;

  async commit(url: string, options: CommitOptions) {
    return this.postFile(url, options);
  }

  async post(url: string) {
    const fetchOptions: RequestInit = {};

    fetchOptions.method = 'POST';
    fetchOptions.headers = {
      Authorization: `Bearer ${this.session.credentials.token}`
    };

    const response = await fetch(url, fetchOptions);

    if (response.status >= HTTP_ERROR_STATUS) {
      const error = await response.text();
      throw new Error(error);
    }

    return response.text();
  }

  async machineTranslationsTranslateFile(
    url: string,
    options: MachineTranslationsTranslateFileOptions
  ) {
    const response = await this.postFile(url, options);

    return response.text();
  }

  async peek(url: string, options: PeekOptions) {
    const response = await this.postFile(url, options);

    return response.json();
  }

  async export(url: string) {
    const options: RequestInit = {};

    options.headers = {
      Authorization: `Bearer ${this.session.credentials.token}`
    };

    const response = await fetch(url, options);

    return response.text();
  }

  private async postFile(
    url: string,
    options:
      | PeekOptions
      | CommitOptions
      | MachineTranslationsTranslateFileOptions
  ) {
    const fetchOptions: RequestInit = {};

    fetchOptions.method = 'POST';
    fetchOptions.headers = {
      Authorization: `Bearer ${this.session.credentials.token}`
    };

    fetchOptions.body = this.setupFormFile(options);

    const response = await fetch(url, fetchOptions);

    if (response.status >= HTTP_ERROR_STATUS) {
      const error = await response.text();
      throw new Error(error);
    }

    return response;
  }

  private setupFormFile(options: {
    file: File;
    version?: string;
    documentPath?: string;
    documentFormat?: string;
  }) {
    const formData = new FormData();
    formData.append('file', options.file);
    if (options.documentPath)
      formData.append('document_path', options.documentPath);
    if (options.documentFormat)
      formData.append('document_format', options.documentFormat);
    if (options.version) formData.append('version', options.version);

    return formData;
  }
}

declare module '@ember/service' {
  interface Registry {
    'authenticated-request': AuthenticatedRequest;
  }
}
