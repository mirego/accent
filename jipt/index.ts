import Accent from './src/accent';

window['accent'].q.forEach(([fun, args]) => Accent[fun](args)); // eslint-disable-line dot-notation
