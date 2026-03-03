import {helper} from '@ember/component/helper';

const LOGOS: Record<string, string> = {
  AZURE_STORAGE_CONTAINER: 'assets/services/azure.svg',
  AWS_S3: 'assets/services/aws-s3.svg',
  DISCORD: 'assets/services/discord.svg',
  GITHUB: 'assets/services/github.svg',
  SLACK: 'assets/services/slack.svg'
};

const integrationLogo = ([service]: [string]) => {
  return LOGOS[service] || '';
};

export default helper(integrationLogo);
