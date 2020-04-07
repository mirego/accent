import {run} from '@ember/runloop';

export default function (application) {
  run(application, 'destroy');
}
