import * as glob from 'glob';
import {DocumentConfig} from '../types/document-config';

export default class Tree {
  private readonly document: DocumentConfig;

  constructor(document: DocumentConfig) {
    this.document = document;
  }

  list(): string[] {
    return glob.sync(this.document.source, {});
  }
}
