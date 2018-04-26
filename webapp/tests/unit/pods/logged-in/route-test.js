import {expect} from 'chai';
import {describe, it, beforeEach, afterEach} from 'mocha';
import {setupTest} from 'ember-mocha';
import sinon from 'sinon';
import Service from '@ember/service';

describe('Unit | Routes | logged-in', () => {
  setupTest('route:logged-in');

  let route;

  describe('redirect()', () => {
    describe('when the user is not authenticated', () => {
      beforeEach(function() {
        const SessionStub = Service.extend({
          isAuthenticated: false
        });

        this.register('service:session', SessionStub);

        route = this.subject();

        sinon.stub(route, 'transitionTo');
      });

      afterEach(() => {
        route.transitionTo.restore();
      });

      it('should redirect them to the login page', () => {
        route.redirect();

        expect(route.transitionTo).to.have.been.calledOnce;
        expect(route.transitionTo).to.have.been.calledWith('login');
      });
    });

    describe('when the user is authenticated', () => {
      beforeEach(function() {
        const SessionStub = Service.extend({
          isAuthenticated: true
        });

        this.register('service:session', SessionStub);

        route = this.subject();

        sinon.stub(route, 'transitionTo');
      });

      afterEach(() => {
        route.transitionTo.restore();
      });

      it('should do nothing', () => {
        route.redirect();

        expect(route.transitionTo).to.not.have.been.called;
      });
    });
  });
});
