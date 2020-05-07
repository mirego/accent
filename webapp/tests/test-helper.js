import Application from '../app';
import config from '../config/environment';
import {setApplication} from '@ember/test-helpers';
import start from 'ember-exam/test-support/start';
import chai from 'chai';
import sinonChai from 'sinon-chai';
import setupChaiDomHelpers from 'ember-chai-dom-helpers/test-support/setup';
import {mocha} from 'mocha';

chai.use(sinonChai);
setupChaiDomHelpers();

mocha.setup({
  slow: 2000,
  timeout: 5000,
});

setApplication(Application.create(config.APP));

start();
