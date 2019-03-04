// Vendor
import {error} from '@oclif/errors'
import * as fs from 'fs-extra'

// Services
import Document from './document'

// Types
import {Config} from '../types/config'

export default class ConfigFetcher {
  public readonly config: Config

  constructor() {
    this.config = fs.readJsonSync('accent.json')
    this.config.apiKey = this.config.apiKey || process.env.ACCENT_API_KEY!
    this.config.apiUrl = this.config.apiUrl || process.env.ACCENT_API_URL!

    if (!this.config.apiKey) {
      error(
        'You must have an apiKey key in the config or the ACCENT_API_KEY environment variable'
      )
    }

    if (!this.config.apiUrl) {
      error(
        'You must have an apiUrl key in the config or the ACCENT_API_URL environment variable'
      )
    }

    if (!this.config.files) {
      error('You must have at least 1 document set in your config')
    }
  }

  public files(): Document[] {
    return this.config.files.map(
      documentConfig => new Document(documentConfig, this.config)
    )
  }
}
