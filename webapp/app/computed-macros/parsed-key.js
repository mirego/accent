export default key => {
  if (!key) return {value: '', prefix: ''};

  const splittedKey = key.split('|');
  const isSplitted = !!splittedKey[1];

  return {
    value: isSplitted ? splittedKey[1] : key,
    prefix: isSplitted ? splittedKey[0] : ''
  };
};
