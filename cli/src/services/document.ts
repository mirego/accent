// Vendor
import * as FormData from 'form-data';
import {CLIError} from '@oclif/errors';
import * as fs from 'fs-extra';
import * as mkdirp from 'mkdirp';
import chalk from 'chalk';
import fetch, {Response} from 'node-fetch';
import * as path from 'path';

// Services
import {fetchFromRevision} from './revision-slug-fetcher';
import Tree from './tree';

// Types
import {Config} from '../types/config';
import {DocumentConfig, NamePattern} from '../types/document-config';
import {OperationResponse} from '../types/operation-response';
import {Project} from '../types/project';

const enum OperationName {
  Sync = 'sync',
  AddTranslation = 'addTranslations',
}

const ERROR_THRESHOLD_STATUS_CODE = 400;

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

  async format(file: string, language: string) {
    const formData = new FormData();

    formData.append('file', fs.createReadStream(file));
    formData.append('document_path', this.parseDocumentName(file, this.config));
    formData.append('document_format', this.config.format);
    formData.append('language', language);
    if (this.projectId) formData.append('project_id', this.projectId);

    const url = `${this.apiUrl}/format`;

    try {
      const response = await fetch(url, {
        body: formData,
        headers: this.authorizationHeader(),
        method: 'POST',
      });

      return this.writeResponseToFile(response, file);
    } catch ({message}) {
      throw new CLIError(chalk.red(`Server error: ${message}`));
    }
  }

  async lint(file: string, language: string) {
    const formData = new FormData();

    formData.append('file', fs.createReadStream(file));
    formData.append('document_path', this.parseDocumentName(file, this.config));
    formData.append('document_format', this.config.format);
    formData.append('language', language);
    if (this.projectId) formData.append('project_id', this.projectId);

    const url = `${this.apiUrl}/lint`;

    try {
      const response = await fetch(url, {
        body: formData,
        headers: this.authorizationHeader(),
        method: 'POST',
      });

      return await response.json();
    } catch ({message}) {
      throw new CLIError(chalk.red(`Server error: ${message}`));
    }
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
    if (options['sync-type']) {
      formData.append('sync_type', options['sync-type']);
    }

    const response = await fetch(url, {
      body: formData,
      headers: this.authorizationHeader(),
      method: 'POST',
    });

    return this.handleResponse(response, options, OperationName.Sync, {file});
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
    if (options['merge-type']) {
      formData.append('merge_type', options['merge-type']);
    }

    const response = await fetch(url, {
      body: formData,
      headers: this.authorizationHeader(),
      method: 'POST',
    });

    return this.handleResponse(
      response,
      options,
      OperationName.AddTranslation,
      {file, documentPath}
    );
  }

  fetchLocalFile(documentPath: string, localPath: string) {
    return this.paths.reduce((memo: string | null, path: string) => {
      if (this.parseDocumentName(path, this.config) === documentPath) {
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
      ['language', language],
    ];

    if (this.projectId) query.push(['project_id', this.projectId]);

    try {
      const url = `${this.apiUrl}/export?${this.encodeQuery(query)}`;
      const response = await fetch(url, {
        headers: this.authorizationHeader(),
      });

      return this.writeResponseToFile(response, file);
    } catch ({message}) {
      throw new CLIError(chalk.red(`Server error: ${message}`));
    }
  }

  async exportJipt(file: string, documentPath: string) {
    const query = [
      ['document_path', documentPath],
      ['document_format', this.config.format],
    ];

    if (this.projectId) query.push(['project_id', this.projectId]);

    const url = `${this.apiUrl}/jipt-export?${this.encodeQuery(query)}`;

    try {
      const response = await fetch(url, {
        headers: this.authorizationHeader(),
      });

      return this.writeResponseToFile(response, file);
    } catch ({message}) {
      throw new CLIError(chalk.red(`Server error: ${message}`));
    }
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

    if (config.namePattern === NamePattern.fileWithSlugSuffix) {
      return basename.replace(path.extname(basename), '');
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
      response.body.pipe(fileStream);
      response.body.on('error', reject);
      fileStream.on('finish', resolve);
    });
  }

  private async handleResponse(
    response: Response,
    options: any,
    operationName: OperationName,
    info: object
  ): Promise<OperationResponse> {
    if (!options['dry-run']) {
      if (response.status >= ERROR_THRESHOLD_STATUS_CODE) {
        return {[operationName]: {success: false}, peek: false, ...info};
      }

      return {[operationName]: {success: true}, peek: false, ...info};
    } else {
      try {
        const {data} = await response.json();

        return {peek: data, [operationName]: {success: true}, ...info};
      } catch ({message}) {
        throw new CLIError(chalk.red(`Server error: ${message}`));
      }
    }
  }
}
