import Component from '@ember/component';
import {computed} from '@ember/object';

import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';

const PLURAL_SUFFIX = /\.(\w)+$/;

// Attributes:
// project: Object <project>
// translation: Object <translation>
export default Component.extend({
  withRevisionLink: true,

  translationKey: parsedKeyProperty('translation.key'),

  revisionName: computed(
    'translation.revision.{name,language.name}',
    function() {
      return (
        this.translation.revision.name ||
        this.translation.revision.language.name
      );
    }
  ),

  versionParam: computed('translation.version.id', function() {
    return this.getWithDefault('translation.version.id', null);
  }),

  pluralBaseKey: computed('translation.key', function() {
    return this.translation.key.replace(PLURAL_SUFFIX, '.');
  })
});
