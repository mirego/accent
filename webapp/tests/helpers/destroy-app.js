/* eslint func-style:0 */

import { run } from '@ember/runloop';

export default function(application) {
  run(application, 'destroy');
}
