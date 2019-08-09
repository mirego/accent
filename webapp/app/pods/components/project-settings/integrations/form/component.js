import {computed} from '@ember/object';
import {inject as service} from '@ember/service';
import {not, reads} from '@ember/object/computed';
import Component from '@ember/component';

// Attributes:
// project: Object <project>
// integration: Object <integration>
// onSubmit: Function
export default Component.extend({
  intl: service('intl'),

  isSubmiting: false,

  errors: [],

  emptyUrl: not('url'),
  url: reads('integration.data.url'),
  repository: reads('integration.data.repository'),
  defaultRef: reads('integration.data.defaultRef'),
  token: reads('integration.data.token'),

  services: ['DISCORD', 'SLACK', 'GITHUB'],

  service: computed('integration', 'services.[]', function() {
    return this.integration.service || this.services[0];
  }),

  serviceValue: computed('service', 'mappedServices', function() {
    return this.mappedServices.find(({value}) => value === this.service);
  }),

  mappedServices: computed('services', function() {
    return this.services.map(value => {
      return {
        label: this.intl.t(`general.integration_services.${value}`),
        value
      };
    });
  }),

  syncChecked: computed('integration.events.[]', function() {
    if (!this.integration.events) return;

    return this.integration.events.includes('SYNC');
  }),

  dataFormComponent: computed('service', function() {
    return `project-settings/integrations/form/${this.service}`;
  }),

  events: computed('syncChecked', function() {
    const data = [];

    if (this.syncChecked) data.push('SYNC');

    return data;
  }),

  didReceiveAttrs() {
    this._super(...arguments);

    if (!this.integration) {
      this.set('integration', {
        newRecord: true,
        service: this.services[0],
        events: [],
        data: {
          url: '',
          repository: '',
          token: '',
          defaultRef: ''
        }
      });
    }
  },

  actions: {
    submit() {
      this.set('isSubmiting', true);

      return this.onSubmit({
        service: this.service,
        events: this.events,
        integration: this.integration.newRecord ? null : this.integration,
        data: {
          url: this.url,
          repository: this.repository,
          token: this.token,
          defaultRef: this.defaultRef
        }
      }).then(({errors}) => {
        this.set('isSubmiting', false);

        if (errors && errors.length > 0) {
          this.set('errors', errors);
        } else {
          if (this.integration.newRecord) {
            this.setProperties({
              syncChecked: false,
              url: ''
            });
          }
        }
      });
    }
  }
});
