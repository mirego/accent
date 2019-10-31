// Vendor
import * as FormData from 'form-data';
import * as fs from 'fs-extra';
import * as mkdirp from 'mkdirp';
import fetch, {Response} from 'node-fetch';
import * as path from 'path';

// Services
import Tree from './tree';

// Types
import {Config} from '../types/config';
import {DocumentConfig, NamePattern} from '../types/document-config';
import {OperationResponse} from '../types/operation-response';
import {Project} from '../types/project';

const enum OperationName {
  Sync = 'sync',
  AddTranslation = 'addTranslations'
}

export default class Document {
  paths: string[];
  readonly apiKey: string;
  readonly apiUrl: string;
  readonly config: DocumentConfig;
  readonly target: string;

  constructor(documentConfig: DocumentConfig, config: Config) {
    this.config = this.resolveNamePattern(documentConfig);
    this.apiKey = config.apiKey;
    this.apiUrl = config.apiUrl;
    this.target = this.config.target;
    this.paths = new Tree(this.config).list();
  }

  refreshPaths() {
    this.paths = new Tree(this.config).list();
  }

  async sync(project: Project, file: string, options: any) {
    const masterLanguage = project!.language.slug;
    const formData = new FormData();
    formData.append('file', fs.createReadStream(file));
    formData.append(
      'document_path',
      this.parseDocumentName(file, this.config.namePattern)
    );
    formData.append('document_format', this.config.format);
    formData.append('language', masterLanguage);

    let url = `${this.apiUrl}/sync`;
    if (!options.write) url = `${url}/peek`;
    if (options['sync-type']) {
      formData.append('sync_type', options['sync-type']);
    }

    const response = await fetch(url, {
      body: formData,
      headers: this.authorizationHeader(),
      method: 'POST'
    });

    return this.handleResponse(response, options, OperationName.Sync);
  }

  async addTranslations(
    file: string,
    language: string,
    documentPath: string,
    options: any
  ) {
    const formData = new FormData();

    formData.append('file', fs.createReadStream(file));
    formData.append('document_path', documentPath);
    formData.append('document_format', this.config.format);
    formData.append('language', language);

    let url = `${this.apiUrl}/add-translations`;
    if (!options.write) url = `${url}/peek`;
    if (options['merge-type']) {
      formData.append('merge_type', options['merge-type']);
    }

    const response = await fetch(url, {
      body: formData,
      headers: this.authorizationHeader(),
      method: 'POST'
    });

    return this.handleResponse(response, options, OperationName.AddTranslation);
  }

  fetchLocalFile(documentPath: string, localPath: string) {
    return this.paths.reduce((memo: string | null, path: string) => {
      if (
        this.parseDocumentName(path, this.config.namePattern) === documentPath
      ) {
        return localPath;
      } else {
        return memo;
      }
    }, null);
  }

  async export(
    file: string,
    language: string,
    documentPath: string,
    options: any
  ) {
    const query = [
      ['document_path', documentPath],
      ['document_format', this.config.format],
      ['order_by', options['order-by']],
      ['language', language]
    ];

    const url = `${this.apiUrl}/export?${this.encodeQuery(query)}`;
    const response = await fetch(url, {
      headers: this.authorizationHeader()
    });

    return this.writeResponseToFile(response, file);
  }

  async exportJipt(file: string, documentPath: string) {
    const query = [
      ['document_path', documentPath],
      ['document_format', this.config.format]
    ];

    const url = `${this.apiUrl}/jipt-export?${this.encodeQuery(query)}`;
    const response = await fetch(url, {
      headers: this.authorizationHeader()
    });

    return this.writeResponseToFile(response, file);
  }

  private encodeQuery(params: string[][]) {
    return params
      .map(([name, value]) => `${name}=${encodeURIComponent(value)}`)
      .join('&');
  }

  private authorizationHeader() {
    return {authorization: `Bearer ${this.apiKey}`};
  }

  private resolveNamePattern(config: DocumentConfig) {
    if (config.namePattern) return config;

    const pattern = config.target.match(/\%slug\%\//)
      ? NamePattern.file
      : NamePattern.parentDirectory;
    config.namePattern = pattern;

    return config;
  }

  private parseDocumentName(file: string, pattern?: NamePattern): string {
    if (pattern === NamePattern.parentDirectory) {
      return path.basename(path.dirname(file));
    }

    if (pattern === NamePattern.fullDirectory) {
      return path.dirname(file);
    }

    return path.basename(file).replace(path.extname(file), '');
  }

  private writeResponseToFile(response: Response, file: string) {
    return new Promise((resolve, reject) => {
      mkdirp.sync(path.dirname(file));

      const fileStream = fs.createWriteStream(file, {autoClose: true});
      response.body.pipe(fileStream);
      response.body.on('error', reject);
      fileStream.on('finish', resolve);
    });
  }

  private async handleResponse(
    response: Response,
    options: any,
    operationName: OperationName
  ): Promise<OperationResponse> {
    if (options.write) {
      if (response.status >= 400) {
        return {[operationName]: {success: false}, peek: false};
      }

      return {[operationName]: {success: true}, peek: false};
    } else {
      const {data} = await response.json();

      return {peek: data, [operationName]: {success: true}};
    }
  }
}
