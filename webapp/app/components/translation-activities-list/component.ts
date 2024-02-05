import Component from '@glimmer/component';

interface Args {
  permissions: Record<string, true>;
  project: any;
  activities: any;
}

export default class TranslationActivitiesList extends Component<Args> {}
