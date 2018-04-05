import Component from '@ember/component';
import {computed} from '@ember/object';

import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';

// Attributes:
// project: Object <project>
// translation: Object <translation>
export default Component.extend({
  translationKey: parsedKeyProperty('translation.key'),

  versionParam: computed('translation.version.id', function() {
    return this.getWithDefault('translation.version.id', null);
  })
});
