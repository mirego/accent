// Vendor
import {error} from '@oclif/errors';
import {execSync} from 'child_process';
import * as fs from 'fs-extra';
import * as path from 'path';
import * as chalk from 'chalk';
// Services
import Document from './document';

// Types
import {Config} from '../types/config';

export default class ConfigFetcher {
  readonly config: Config;
  readonly warnings: string[];

  constructor(configFilePath: string) {
    this.config = fs.readJsonSync(configFilePath);
    this.config.apiKey = process.env.ACCENT_API_KEY || this.config.apiKey;
    this.config.apiUrl = process.env.ACCENT_API_URL || this.config.apiUrl;
    this.config.project = process.env.ACCENT_PROJECT || this.config.project;

    this.warnings = [];

    if (!this.config.apiKey) {
      error(
        'You must have an apiKey key in the config or the ACCENT_API_KEY environment variable'
      );
    }

    if (!this.config.apiUrl) {
      error(
        'You must have an apiUrl key in the config or the ACCENT_API_URL environment variable'
      );
    }

    if (!this.config.files) {
      error('You must have at least 1 document set in your config');
    }

    if (
      this.config.version?.branchVersionPrefix &&
      this.getCurrentBranchName().startsWith(
        this.config.version?.branchVersionPrefix
      )
    ) {
      this.config.version.tag = this.extractVersionFromBranch(
        this.getCurrentBranchName(),
        this.config.version?.branchVersionPrefix
      );
    }

    const sameFolderPathWarning: Set<string> = new Set();

    this.config.files.forEach((documentConfig) => {
      const folderPath = this.sourceFolderPath(documentConfig.source);

      const sameFolderPath = this.config.files
        .filter(({source}) => source !== documentConfig.source)
        .some(
          (otherDocumentConfig) =>
            this.sourceFolderPath(otherDocumentConfig.source) === folderPath
        );

      if (sameFolderPath) sameFolderPathWarning.add(folderPath);
    });

    sameFolderPathWarning.forEach((folderPath) => {
      this.warnings.push(
        `Some files in your config file as the same folder path: ${chalk.bold(
          folderPath
        )}
Only your master language should be listed in your files config.`
      );
    });
  }

  files(): Document[] {
    return this.config.files.map(
      (documentConfig) => new Document(documentConfig, this.config)
    );
  }

  private sourceFolderPath(source: string) {
    return source.replace(path.basename(source), '');
  }

  private getCurrentBranchName() {
    try {
      return execSync('git rev-parse --abbrev-ref HEAD')
        .toString('utf8')
        .replace(/[\n\r\s]+$/, '');
    } catch {
      return '';
    }
  }

  private extractVersionFromBranch(
    branchName: string,
    gitBranchVersionMatch: string
  ): string {
    return branchName.replace(gitBranchVersionMatch, '');
  }
}
