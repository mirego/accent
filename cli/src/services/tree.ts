// Vendor
import * as glob from 'glob'

// Types
import {DocumentConfig} from '../types/document-config'

export default class Tree {
  private readonly document: DocumentConfig

  constructor(document: DocumentConfig) {
    this.document = document
  }

  public list(): string[] {
    return glob.sync(this.document.source, {})
  }
}
