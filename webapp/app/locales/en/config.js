export default {
  pluralForm(n) {
    if (n === 0) return 'zero';
    if (n === 1) return 'one';

    return 'other';
  }
};
