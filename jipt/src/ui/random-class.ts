/* Random class that should not conflict with the parent window styles */
export default () =>
  `acc_${Math.random()
    .toString(36)
    .substring(8)}`;
