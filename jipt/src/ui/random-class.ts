const BASE = 36;
const LENGTH = 8;

/* Random class that should not conflict with the parent window styles */
export default () => `acc_${Math.random().toString(BASE).substring(LENGTH)}`;
