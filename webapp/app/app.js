import Application from '@ember/application';
import Ember from 'ember';
import Resolver from './resolver';
import loadInitializers from 'ember-load-initializers';
import config from './config/environment';

Ember.MODEL_FACTORY_INJECTIONS = true;

const {modulePrefix, podModulePrefix} = config;
const App = Application.extend({
  modulePrefix,
  podModulePrefix,
  Resolver
});

loadInitializers(App, modulePrefix);

export default App;
