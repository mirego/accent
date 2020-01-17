import Application from '@ember/application';
import Resolver from 'ember-resolver';
import loadInitializers from 'ember-load-initializers';
import config from './config/environment';

const {modulePrefix, podModulePrefix} = config;

class App extends Application {
  modulePrefix = modulePrefix;
  podModulePrefix = podModulePrefix;
  Resolver = Resolver;
}

loadInitializers(App, modulePrefix);

export default App;
