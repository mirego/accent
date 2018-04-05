import Component from '@ember/component';

// Attributes:
// onSubmit: Function
export default Component.extend({
  text: null,
  loading: false,
  error: false,

  actions: {
    submit() {
      this._onLoading();

      this.onSubmit(this.text)
        .then(this._onSuccess.bind(this))
        .catch(this._onError.bind(this));
    }
  },

  _onLoading() {
    this.set('error', false);
    this.set('loading', true);
  },

  _onError() {
    this.set('loading', false);
    this.set('error', true);
  },

  _onSuccess() {
    this.set('loading', false);
    this.set('text', null);
  }
});
