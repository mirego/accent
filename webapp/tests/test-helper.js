import resolver from './helpers/resolver';
import './helpers/flash-message';

import registerSelectHelper from './helpers/register-select-helper';
registerSelectHelper();
import { setResolver } from 'ember-mocha';

setResolver(resolver);
