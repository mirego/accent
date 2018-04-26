import Application from '../../app';
import config from '../../config/environment';
import {run} from '@ember/runloop';

export default function startApp(attrs) {
  const attributes = {...config.APP, autoboot: false, ...attrs};

  return run(() => {
    const application = Application.create(attributes);
    application.setupForTesting();
    application.injectTestHelpers();
    return application;
  });
}
