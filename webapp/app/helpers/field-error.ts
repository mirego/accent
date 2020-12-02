import {helper} from '@ember/component/helper';

interface Error {
  field: String;
}

const fieldError = ([errors, fieldName]: [[Error], string]): boolean => {
  return !!(errors && errors.find(({field}) => field === fieldName)) || false;
};

export default helper(fieldError);
