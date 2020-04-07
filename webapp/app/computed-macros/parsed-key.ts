interface ParsedKey {
  value: String;
  prefix: String;
}

export default (key: String): ParsedKey => {
  if (!key) return {value: '', prefix: ''};

  const splittedKey = key.split('|');
  const isSplitted = !!splittedKey[1];

  return {
    value: isSplitted ? splittedKey[1] : key,
    prefix: isSplitted ? splittedKey[0] : '',
  };
};
