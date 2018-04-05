import EmberObject, {computed} from '@ember/object';

export default property => {
  return computed(property, function() {
    const key = this.get(property);

    if (!key) return EmberObject.create({value: '', prefix: ''});

    const splittedKey = key.split('|');
    const isSplitted = !!splittedKey[1];

    return EmberObject.create({
      value: isSplitted ? splittedKey[1] : key,
      prefix: isSplitted ? splittedKey[0] : ''
    });
  });
};
