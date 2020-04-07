import Service, {inject as service} from '@ember/service';
import Apollo from 'accent-webapp/services/apollo';

export default class ApolloMutate extends Service {
  @service('apollo')
  apollo: Apollo;

  async mutate(args: any) {
    const {data} = await this.apollo.client.mutate(args);

    return this.resolve(data);
  }

  private resolve(data: Record<string, any>) {
    const operationName = Object.keys(data)[0];

    if (data[operationName].errors && data[operationName].errors.length > 0) {
      throw new Error(data[operationName].errors);
    }

    return data[operationName];
  }
}

declare module '@ember/service' {
  interface Registry {
    'apollo-mutate': ApolloMutate;
  }
}
