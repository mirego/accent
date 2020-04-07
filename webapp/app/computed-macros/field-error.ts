interface Error {
  field: String;
}

export default (errors: [Error], property: String): Error | undefined =>
  errors && errors.find(({field}) => field === property);
