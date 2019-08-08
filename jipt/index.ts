import Accent from './src/accent';

window['accent'].q.forEach(([fun, args]) => Accent[fun](args));
