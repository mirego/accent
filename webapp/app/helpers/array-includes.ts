import {helper} from '@ember/component/helper';

const arrayIncludes = ([container, item]: [any[], any]) => {
  return container.includes(item);
};

export default helper(arrayIncludes);
