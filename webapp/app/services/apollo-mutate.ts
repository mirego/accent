import Service, {inject as service} from '@ember/service';
import Apollo from 'accent-webapp/services/apollo';

export interface MutationResponse {
  errors: string[] | null;
}

export default class ApolloMutate extends Service {
  @service('apollo')
  apollo: Apollo;

  async mutate(args: any) {
    try {
      const {data} = await this.apollo.client.mutate(args);
      const operationName = Object.keys(data)[0];

      if (!data[operationName]?.errors?.length) {
        const updatedData = {
          data,
          [operationName]: {...data[operationName], errors: null},
        };
        return updatedData;
      }

      return data[operationName];
    } catch {
      return {errors: ['internal_server_error'], data: null};
    }
  }
}

declare module '@ember/service' {
  interface Registry {
    'apollo-mutate': ApolloMutate;
  }
}
