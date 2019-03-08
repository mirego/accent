// Vendor
import Command from '@oclif/command'
import {error} from '@oclif/errors'
import chalk from 'chalk'
import cli from 'cli-ux'

// Services
import ConfigFetcher from './services/config'
import ProjectFetcher from './services/project-fetcher'

// Types
import {Project} from './types/project'

const sleep = (ms: number) =>
  new Promise((resolve: () => void) => setTimeout(resolve, ms))

export default abstract class extends Command {
  public projectConfig: ConfigFetcher = new ConfigFetcher()
  public project?: Project

  public async init() {
    const config = this.projectConfig.config
    if (!config.apiUrl) error('You must set an API url in your config')
    if (!config.apiKey) error('You must set an API key in your config')

    // Fetch project from the GraphQL API.
    cli.action.start(chalk.white('Fetch config'))
    await sleep(1000)
    const fetcher = new ProjectFetcher()
    this.project = await fetcher.fetch(config)
    cli.action.stop(chalk.green('✓'))
    console.log('')
  }

  public async refreshProject() {
    const config = this.projectConfig.config

    const fetcher = new ProjectFetcher()
    this.project = await fetcher.fetch(config)
  }
}
