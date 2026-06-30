import Component from '@glimmer/component';
import {action} from '@ember/object';
import DataControlText from 'accent-webapp/components/project-settings/integrations/form/data-control-text/index';
import fieldError from 'accent-webapp/helpers/field-error';
import t from 'ember-intl/helpers/t';
import HighlightRender from 'accent-webapp/components/highlight-render/index';

interface Args {
  errors: any;
  project: any;
  bucket: string | null;
  pathPrefix: string | null;
  onChangeBucket: (value: string) => void;
  onChangePathPrefix: (value: string) => void;
  onChangeRegion: (value: string) => void;
  onChangeAccessKeyId: (value: string) => void;
  onChangeSecretAccessKey: (value: string) => void;
}

export default class AwsS3 extends Component<Args> {
  <template>
    <div class='container'>
      <div class='form'>

        <DataControlText
          @error={{fieldError @errors 'data.awsS3Bucket'}}
          @label={{t
            'components.project_settings.integrations.data.aws_s3_bucket'
          }}
          @value={{@bucket}}
          @onChange={{this.changeBucket}}
        />

        <DataControlText
          @error={{fieldError @errors 'data.awsS3PathPrefix'}}
          @label={{t
            'components.project_settings.integrations.data.aws_s3_path_prefix'
          }}
          @value={{@pathPrefix}}
          @placeholder='/'
          @onChange={{this.changePathPrefix}}
        />

        <DataControlText
          @error={{fieldError @errors 'data.awsS3Region'}}
          @label={{t
            'components.project_settings.integrations.data.aws_s3_region'
          }}
          @value={{@region}}
          @placeholder='us-east-1'
          @onChange={{this.changeRegion}}
        />

        <DataControlText
          @error={{fieldError @errors 'data.awsS3AccessKeyId'}}
          @label={{t
            'components.project_settings.integrations.data.aws_s3_access_key_id'
          }}
          @value={{@accessKeyId}}
          @onChange={{this.changeAccessKeyId}}
        />

        <DataControlText
          @error={{fieldError @errors 'data.awsS3SecretAccessKey'}}
          @label={{t
            'components.project_settings.integrations.data.aws_s3_secret_access_key'
          }}
          @onChange={{this.changeSecretAccessKey}}
        />
      </div>
      <div class='policy'>
        <label class='policy-title'>
          {{t
            'components.project_settings.integrations.data.aws_s3_minimum_policy'
          }}
        </label>

        <div class='policy-render'>
          <HighlightRender @content={{this.policyContent}} />
        </div>
      </div>
    </div>
  </template>
  get policyContent() {
    const bucket = this.args.bucket || '-';
    const pathPrefix = this.args.pathPrefix || '/';

    return `{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:PutObject"],
      "Resource": "arn:aws:s3:::${bucket}${pathPrefix}*"
    }
  ]
}`;
  }

  @action
  changeBucket(event: Event) {
    const target = event.target as HTMLInputElement;

    this.args.onChangeBucket(target.value);
  }

  @action
  changePathPrefix(event: Event) {
    const target = event.target as HTMLInputElement;

    this.args.onChangePathPrefix(target.value);
  }

  @action
  changeRegion(event: Event) {
    const target = event.target as HTMLInputElement;

    this.args.onChangeRegion(target.value);
  }

  @action
  changeAccessKeyId(event: Event) {
    const target = event.target as HTMLInputElement;

    this.args.onChangeAccessKeyId(target.value);
  }

  @action
  changeSecretAccessKey(event: Event) {
    const target = event.target as HTMLInputElement;

    this.args.onChangeSecretAccessKey(target.value);
  }
}
