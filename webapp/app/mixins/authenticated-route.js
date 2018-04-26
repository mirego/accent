import {inject as service} from '@ember/service';
import Mixin from '@ember/object/mixin';

export default Mixin.create({
  session: service(),

  redirect() {
    if (!this.session.isAuthenticated) {
      this.transitionTo('login');
    }
  }
});
