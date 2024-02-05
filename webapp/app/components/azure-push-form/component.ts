import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';

interface Args {
  error: boolean;
  project: any;
  onPush: ({
    targetVersion,
    specificVersion,
  }: {
    targetVersion: string;
    specificVersion: string | null;
  }) => Promise<void>;
}

export default class AzurePushForm extends Component<Args> {
  allTargetVersions = [
    {
      value: 'LATEST',
      label:
        'components.project_settings.integrations.target_version.options.latest',
    },
    {
      value: 'SPECIFIC',
      label:
        'components.project_settings.integrations.target_version.options.specific',
    },
    {
      value: 'ALL',
      label:
        'components.project_settings.integrations.target_version.options.all',
    },
  ];

  @tracked
  targetVersion = this.allTargetVersions[0].value;

  @tracked
  specificVersion: string | null;

  @tracked
  isSubmitting = false;

  @action
  async submit() {
    this.isSubmitting = true;

    await this.args.onPush({
      targetVersion: this.targetVersion,
      specificVersion: this.specificVersion,
    });

    this.isSubmitting = false;
  }

  @action
  setTargetVersion(targetVersion: string) {
    this.targetVersion = targetVersion;
  }
  @action
  setSpecificVersion(event: Event) {
    const target = event.target as HTMLInputElement;

    this.specificVersion = target.value;
  }
}
