// Vendor
import * as FormData from 'form-data';
import {CLIError} from '@oclif/errors';
import * as fs from 'fs-extra';
import * as mkdirp from 'mkdirp';
import * as chalk from 'chalk';
import * as path from 'path';
import fetch, {Response} from 'node-fetch';

// Services
import {fetchFromRevision} from './revision-slug-fetcher';
import Tree from './tree';

// Types
import {Config} from '../types/config';
import {DocumentConfig, NamePattern} from '../types/document-config';
import {OperationResponse} from '../types/operation-response';
import {Project} from '../types/project';

const SERVER_INTERNAL_ERROR_THRESHOLD_STATUS_CODE = 400;

const throwOnServerError = async (response: Response) => {
  if (response.status >= SERVER_INTERNAL_ERROR_THRESHOLD_STATUS_CODE) {
    throw new CLIError(chalk.red(`${await response.text()}`), {exit: 1});
  }
};

interface FormatOptions {
  'order-by': string;
}

export default class Document {
  paths: string[];
  readonly apiKey: string;
  readonly apiUrl: string;
  readonly projectId: string | null | undefined;
  readonly config: DocumentConfig;
  readonly target: string;

  constructor(documentConfig: DocumentConfig, config: Config) {
    this.config = this.resolveNamePattern(documentConfig);
    this.apiKey = config.apiKey;
    this.apiUrl = config.apiUrl;
    this.projectId = config.project;
    this.target = this.config.target;
    this.paths = new Tree(this.config).list();
  }

  refreshPaths() {
    this.paths = new Tree(this.config).list();
  }

  async format(file: string, language: string, options: FormatOptions) {
    const formData = new FormData();

    formData.append('file', fs.createReadStream(file));
    formData.append('document_path', this.parseDocumentName(file, this.config));
    formData.append('document_format', this.config.format);
    formData.append('language', language);
    if (this.projectId) formData.append('project_id', this.projectId);
    if (options['order-by']) formData.append('order_by', options['order-by']);

    const url = `${this.apiUrl}/format`;

    const response = await fetch(url, {
      body: formData,
      headers: this.authorizationHeader(),
      method: 'POST',
    });

    await throwOnServerError(response);

    return this.writeResponseToFile(response, file);
  }

  async lint(file: string, language: string) {
    const formData = new FormData();

    formData.append('file', fs.createReadStream(file));
    formData.append('document_path', this.parseDocumentName(file, this.config));
    formData.append('document_format', this.config.format);
    formData.append('language', language);
    if (this.projectId) formData.append('project_id', this.projectId);

    const url = `${this.apiUrl}/lint`;

    const response = await fetch(url, {
      body: formData,
      headers: this.authorizationHeader(),
      method: 'POST',
    });

    await throwOnServerError(response);

    return await response.json();
  }

  async sync(project: Project, file: string, options: any) {
    const masterLanguage = fetchFromRevision(project.masterRevision);
    const formData = new FormData();
    formData.append('file', fs.createReadStream(file));
    formData.append('document_path', this.parseDocumentName(file, this.config));
    formData.append('document_format', this.config.format);
    formData.append('language', masterLanguage);
    if (this.projectId) formData.append('project_id', this.projectId);

    let url = `${this.apiUrl}/sync`;
    if (options['dry-run']) url = `${url}/peek`;
    if (options.version) formData.append('version', options.version);
    if (options['sync-type']) {
      formData.append('sync_type', options['sync-type']);
    }

    const response = await fetch(url, {
      body: formData,
      headers: this.authorizationHeader(),
      method: 'POST',
    });

    await throwOnServerError(response);

    return this.handleResponse(response, options, {file});
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
    if (this.projectId) formData.append('project_id', this.projectId);

    let url = `${this.apiUrl}/add-translations`;
    if (options['dry-run']) url = `${url}/peek`;
    if (options.version) formData.append('version', options.version);
    if (options['merge-type']) {
      formData.append('merge_type', options['merge-type']);
    }

    const response = await fetch(url, {
      body: formData,
      headers: this.authorizationHeader(),
      method: 'POST',
    });

    await throwOnServerError(response);

    return this.handleResponse(response, options, {file, documentPath});
  }

  fetchLocalFile(documentPath: string, localPath: string) {
    return this.paths.reduce((memo: string, path: string) => {
      if (this.parseDocumentName(path, this.config) === documentPath) {
        return localPath;
      } else {
        return memo;
      }
    }, localPath);
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
      ['language', language],
    ];

    if (options.version) query.push(['version', options.version]);
    if (this.projectId) query.push(['project_id', this.projectId]);

    const url = `${this.apiUrl}/export?${this.encodeQuery(query)}`;
    const response = await fetch(url, {
      headers: this.authorizationHeader(),
    });
    await throwOnServerError(response);

    return this.writeResponseToFile(response, file);
  }

  async exportJipt(file: string, documentPath: string) {
    const query = [
      ['document_path', documentPath],
      ['document_format', this.config.format],
    ];

    if (this.projectId) query.push(['project_id', this.projectId]);

    const url = `${this.apiUrl}/jipt-export?${this.encodeQuery(query)}`;

    const response = await fetch(url, {
      headers: this.authorizationHeader(),
    });
    await throwOnServerError(response);

    return this.writeResponseToFile(response, file);
  }

  parseDocumentName(file: string, config: DocumentConfig): string {
    if (config.namePattern === NamePattern.parentDirectory) {
      const targetPrefixMatch = config.target.match(/(\w+\/)+/);

      if (targetPrefixMatch) {
        return path.dirname(file).replace(targetPrefixMatch[0], '');
      } else {
        return path.dirname(file);
      }
    }

    const basename = path.basename(file).replace(path.extname(file), '');

    if (config.namePattern === NamePattern.fileWithParentDirectory) {
      const languageIndex = config.target.split(path.sep).indexOf('%slug%') + 1;
      const pathParts = file.split(path.sep);
      const resultPath = pathParts.splice(
        languageIndex,
        pathParts.length - languageIndex - 1
      );
      return resultPath.length > 0
        ? resultPath.join(path.sep).concat(path.sep).concat(basename)
        : basename;
    }

    if (config.namePattern === NamePattern.fileWithSlugSuffix) {
      return basename.split('.')[0];
    }

    return basename;
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
    let pattern = NamePattern.parentDirectory;

    if (config.target.match(/%slug%\//) || !config.source.match(/\//)) {
      pattern = NamePattern.file;
    }

    if (config.target.match(/\.%slug%\./)) {
      pattern = NamePattern.fileWithSlugSuffix;
    }

    config.namePattern = pattern;

    return config;
  }

  private async writeResponseToFile(response: Response, file: string) {
    return new Promise((resolve, reject) => {
      mkdirp.sync(path.dirname(file));

      const fileStream = fs.createWriteStream(file, {autoClose: true});
      response.body?.pipe(fileStream);
      response.body?.on('error', reject);
      fileStream.on('finish', resolve);
    });
  }

  private async handleResponse(
    response: Response,
    options: any,
    info: object
  ): Promise<OperationResponse> {
    if (!options['dry-run']) {
      return {peek: false, ...info};
    } else {
      const {data} = (await response.json()) as {data: any};

      return {peek: data, ...info};
    }
  }
}
