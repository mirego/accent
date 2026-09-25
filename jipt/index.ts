import Accent from './src/accent.ts';

window['accent'].q.forEach(([fun, args]) => Accent[fun](args));
