import Service, {inject as service} from '@ember/service';
import fetch from 'fetch';
import Session from 'accent-webapp/services/session';

const HTTP_ERROR_STATUS = 400;

interface CommitOptions {
  file: File;
  documentPath: string;
  documentFormat: string;
  syncType?: string;
}

interface PeekOptions {
  file: File;
  documentPath: string;
  documentFormat: string;
}

export default class AuthenticatedRequest extends Service {
  @service('session')
  session: Session;

  async commit(url: string, options: CommitOptions) {
    return this.postFile(url, options);
  }

  async peek(url: string, options: PeekOptions) {
    const response = await this.postFile(url, options);

    return response.json();
  }

  async export(url: string) {
    const options: RequestInit = {};

    options.headers = {
      Authorization: `Bearer ${this.session.credentials.token}`,
    };

    const response = await fetch(url, options);

    return response.text();
  }

  private async postFile(url: string, options: PeekOptions | CommitOptions) {
    const fetchOptions: RequestInit = {};

    fetchOptions.method = 'POST';
    fetchOptions.headers = {
      Authorization: `Bearer ${this.session.credentials.token}`,
    };

    fetchOptions.body = this.setupFormFile(options);

    const response = await fetch(url, fetchOptions);

    if (response.status >= HTTP_ERROR_STATUS) {
      const error = await response.text();
      throw new Error(error);
    }

    return response;
  }

  private setupFormFile({
    file,
    documentPath,
    documentFormat,
  }: {
    file: File;
    documentPath: string;
    documentFormat: string;
  }) {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('document_path', documentPath);
    formData.append('document_format', documentFormat);

    return formData;
  }
}

declare module '@ember/service' {
  interface Registry {
    'authenticated-request': AuthenticatedRequest;
  }
}
