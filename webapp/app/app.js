import Application from '@ember/application';
import compatModules from '@embroider/virtual/compat-modules';
import Resolver from 'ember-resolver';
import loadInitializers from 'ember-load-initializers';
import {setConfig} from 'ember-basic-dropdown/config';
import 'ember-basic-dropdown/styles';
import config from './config/environment';

setConfig({
  rootElement: config.APP.rootElement
});

export default class App extends Application {
  modulePrefix = config.modulePrefix;
  Resolver = Resolver.withModules(compatModules);
}

loadInitializers(App, config.modulePrefix, compatModules);
