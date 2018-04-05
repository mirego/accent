import {computed} from '@ember/object';
import {not, reads} from '@ember/object/computed';
import Component from '@ember/component';

// Attributes:
// project: Object <project>
// integration: Object <integration>
// onSubmit: Function
export default Component.extend({
  isSubmiting: false,
  emptyUrl: not('url'),
  url: reads('integration.data.url'),
  services: ['SLACK'],

  service: computed('services.[]', function() {
    return this.services[0];
  }),

  serviceValue: computed('service', 'mappedServices', function() {
    return this.mappedServices.find(({value}) => value === this.service);
  }),

  mappedServices: computed('services', function() {
    return this.services.map(value => {
      return {label: `general.integration_services.${value}`, value};
    });
  }),

  syncChecked: computed('integration.events.[]', function() {
    return this.integration.events.includes('SYNC');
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
          url: ''
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
          url: this.url
        }
      })
        .then(() => this.set('isSubmiting', false))
        .then(() => {
          if (this.integration.newRecord) {
            this.setProperties({
              syncChecked: false,
              url: ''
            });
          }
        });
    }
  }
});
