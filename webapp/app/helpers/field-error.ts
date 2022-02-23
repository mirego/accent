import {helper} from '@ember/component/helper';

interface Error {
  field: string;
}

const fieldError = ([errors, fieldName]: [[Error], string]): boolean => {
  return !!(errors && errors.find(({field}) => field === fieldName)) || false;
};

export default helper(fieldError);
