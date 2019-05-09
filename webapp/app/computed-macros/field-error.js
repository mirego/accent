import {computed} from '@ember/object';

export default (errorsKey, property) => {
  return computed(errorsKey, function() {
    const errors = this.get(errorsKey);

    return errors && errors.find(({field}) => field === property);
  });
};
