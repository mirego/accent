import Service, {inject as service} from '@ember/service';
import Apollo from 'accent-webapp/services/apollo';

export interface MutationResponse {
  errors: string[] | null;
}

export default class ApolloMutate extends Service {
  @service('apollo')
  apollo: Apollo;

  async mutate(args: any) {
    const {data} = await this.apollo.client.mutate(args);
    const operationName = Object.keys(data)[0];

    if (!data[operationName]?.errors?.length) {
      data[operationName].errors = null;

      return data[operationName];
    }

    return data[operationName];
  }
}

declare module '@ember/service' {
  interface Registry {
    'apollo-mutate': ApolloMutate;
  }
}
