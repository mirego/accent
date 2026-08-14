import Application from 'accent-webapp/app';
import config from 'accent-webapp/config/environment';
import {setApplication} from '@ember/test-helpers';
import {start as qunitStart, setupEmberOnerrorValidation} from 'ember-qunit';

export function start() {
  setApplication(Application.create(config.APP));

  setupEmberOnerrorValidation();
  qunitStart();
}
