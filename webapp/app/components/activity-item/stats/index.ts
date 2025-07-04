import {service} from '@ember/service';
import Component from '@glimmer/component';
import {underscore} from '@ember/string';
import IntlService from 'ember-intl/services/intl';

interface Args {
  componentTranslationPrefix: string;
  stats: Array<{
    action: string;
    count: number;
  }>;
}

export default class ActivityItemStats extends Component<Args> {
  @service('intl')
  declare intl: IntlService;

  get localizedStats() {
    return this.args.stats.map((stat: any) => {
      const text = this.intl.t(
        `components.${
          this.args.componentTranslationPrefix
        }.stats_text.${underscore(stat.action)}`
      );

      const count = stat.count;

      return {text, count};
    });
  }
}
