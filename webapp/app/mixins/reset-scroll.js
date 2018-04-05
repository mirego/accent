import Mixin from '@ember/object/mixin';

export default Mixin.create({
  activate() {
    this._super();

    window.scrollTo(0, 0);
  }
});
