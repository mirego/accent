import {helper} from '@ember/component/helper';

const repeat = ([length]: [number]) => {
  return Array.from(Array(length));
};

export default helper(repeat);
