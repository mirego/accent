// Vendor
import * as FormData from 'form-data'
import * as fs from 'fs-extra'
import fetch, {Response} from 'node-fetch'
import * as path from 'path'

// Services
import Tree from './tree'

// Types
import {Config} from '../types/config'
import {DocumentConfig} from '../types/document-config'
import {OperationResponse} from '../types/operation-response'

const enum OperationName {
  Sync = 'sync',
  AddTranslation = 'addTranslations'
}

export default class Document {
  public paths: string[]
  public readonly apiKey: string
  public readonly apiUrl: string
  public readonly config: DocumentConfig
  public readonly target: string

  constructor(documentConfig: DocumentConfig, config: Config) {
    this.config = documentConfig
    this.apiKey = config.apiKey
    this.apiUrl = config.apiUrl
    this.target = this.config.target
    this.paths = new Tree(this.config).list()
  }

  public refreshPaths() {
    this.paths = new Tree(this.config).list()
  }

  public async sync(file: string, options: any) {
    const formData = new FormData()
    formData.append('file', fs.createReadStream(file))
    formData.append('document_path', this.parseDocumentName(file))
    formData.append('document_format', this.config.format)
    formData.append('language', this.config.language)

    let url = `${this.apiUrl}/sync`
    if (!options.write) url = `${url}/peek`
    if (options['sync-type']) formData.append('sync_type', options['sync-type'])

    const response = await fetch(url, {
      body: formData,
      headers: this.authorizationHeader(),
      method: 'POST'
    })

    return this.handleResponse(response, options, OperationName.Sync)
  }

  public async addTranslations(
    file: string,
    language: string,
    documentPath: string,
    options: any
  ) {
    const formData = new FormData()

    formData.append('file', fs.createReadStream(file))
    formData.append('document_path', documentPath)
    formData.append('document_format', this.config.format)
    formData.append('language', language)

    let url = `${this.apiUrl}/add-translations`
    if (!options.write) url = `${url}/peek`
    if (options['merge-type']) {
      formData.append('merge_type', options['merge-type'])
    }

    const response = await fetch(url, {
      body: formData,
      headers: this.authorizationHeader(),
      method: 'POST'
    })

    return this.handleResponse(response, options, OperationName.AddTranslation)
  }

  public async export(
    file: string,
    language: string,
    documentPath: string,
    options: any
  ) {
    language = language || this.config.language

    const query = [
      ['document_path', documentPath],
      ['document_format', this.config.format],
      ['order_by', options['order-by']],
      ['language', language]
    ]
      .map(([name, value]) => `${name}=${value}`)
      .join('&')

    const url = `${this.apiUrl}/export?${query}`
    const response = await fetch(url, {
      headers: this.authorizationHeader()
    })

    return this.writeResponseToFile(response, file)
  }

  public async exportJipt(file: string, documentPath: string) {
    const query = [
      ['document_path', documentPath],
      ['document_format', this.config.format]
    ]
      .map(([name, value]) => `${name}=${value}`)
      .join('&')

    const url = `${this.apiUrl}/jipt-export?${query}`
    const response = await fetch(url, {
      headers: this.authorizationHeader()
    })

    return this.writeResponseToFile(response, file)
  }

  private authorizationHeader() {
    return {authorization: `Bearer ${this.apiKey}`}
  }

  private parseDocumentName(file: string): string {
    return path.basename(file).replace(path.extname(file), '')
  }

  private writeResponseToFile(response: Response, file: string) {
    return new Promise((resolve, reject) => {
      const fileStream = fs.createWriteStream(file, {autoClose: true})
      response.body.pipe(fileStream)
      response.body.on('error', reject)
      fileStream.on('finish', resolve)
    })
  }

  private async handleResponse(
    response: Response,
    options: any,
    operationName: OperationName
  ): Promise<OperationResponse> {
    if (options.write) {
      if (response.status >= 400) {
        return {[operationName]: {success: false}, peek: false}
      }

      return {[operationName]: {success: true}, peek: false}
    } else {
      const {data} = await response.json()

      return {peek: data, [operationName]: {success: true}}
    }
  }
}
