import Application from '../app';
import config from '../config/environment';
import {setApplication} from '@ember/test-helpers';

setApplication(Application.create(config.APP));
