import Component from '@glimmer/component';
import AwsS3Svg from 'accent-webapp/svgs/assets/services/aws-s3.svg';
import AzureSvg from 'accent-webapp/svgs/assets/services/azure.svg';
import DiscordSvg from 'accent-webapp/svgs/assets/services/discord.svg';
import GithubSvg from 'accent-webapp/svgs/assets/services/github.svg';
import SlackSvg from 'accent-webapp/svgs/assets/services/slack.svg';

interface Args {
  service: string;
}

export default class IntegrationLogo extends Component<Args> {
  <template>
    {{#if this.isAzure}}
      <AzureSvg ...attributes />
    {{else if this.isAwsS3}}
      <AwsS3Svg ...attributes />
    {{else if this.isDiscord}}
      <DiscordSvg ...attributes />
    {{else if this.isGithub}}
      <GithubSvg ...attributes />
    {{else if this.isSlack}}
      <SlackSvg ...attributes />
    {{/if}}
  </template>

  get isAzure() {
    return this.args.service === 'AZURE_STORAGE_CONTAINER';
  }

  get isAwsS3() {
    return this.args.service === 'AWS_S3';
  }

  get isDiscord() {
    return this.args.service === 'DISCORD';
  }

  get isGithub() {
    return this.args.service === 'GITHUB';
  }

  get isSlack() {
    return this.args.service === 'SLACK';
  }
}
