import Component from '@glimmer/component';
import {action} from '@ember/object';

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
