import Service, {inject as service} from '@ember/service';
import RSVP from 'rsvp';
import fetch from 'fetch';

const HTTP_ERROR_STATUS = 400;

export default Service.extend({
  session: service('session'),

  postFile(url, options) {
    options.method = 'POST';
    options.headers = {
      Authorization: `Bearer ${this.session.credentials.token}`
    };
    options.body = this._setupFormFile(options);
    delete options.file;

    return new RSVP.Promise((resolve, reject) => {
      return fetch(url, options).then(response => {
        if (response.status >= HTTP_ERROR_STATUS) return reject(response);

        return resolve(response);
      });
    });
  },

  commit(url, options) {
    return new RSVP.Promise((resolve, reject) => {
      return this.postFile(url, options)
        .then(resolve)
        .catch(reject);
    });
  },

  peek(url, options) {
    return new RSVP.Promise((resolve, reject) => {
      return this.postFile(url, options)
        .then(data => data.json().then(resolve))
        .catch(reject);
    });
  },

  export(url, options) {
    options.headers = {
      Authorization: `Bearer ${this.session.credentials.token}`
    };

    return new RSVP.Promise((resolve, reject) => {
      return fetch(url, options)
        .then(data => data.text().then(resolve))
        .catch(reject);
    });
  },

  _setupFormFile({file, documentPath, documentFormat}) {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('document_path', documentPath);
    formData.append('document_format', documentFormat);

    return formData;
  }
});
