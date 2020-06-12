import {helper} from '@ember/component/helper';

const repeat = ([length]: [number]) => {
  return Array.apply(null, {length});
};

export default helper(repeat);
