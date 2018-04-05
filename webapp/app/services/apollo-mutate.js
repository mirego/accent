import Service, {inject as service} from '@ember/service';
import RSVP from 'rsvp';

export default Service.extend({
  apollo: service(),

  mutate(args) {
    return this.apollo.client.mutate(args).then(this._resolve);
  },

  _resolve({data}) {
    return new RSVP.Promise((resolve, reject) => {
      const operationName = Object.keys(data)[0];

      data[operationName].errors ? reject(data[operationName].errors) : resolve(data[operationName]);
    });
  }
});
