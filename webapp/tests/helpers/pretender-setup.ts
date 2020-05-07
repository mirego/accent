import Pretender from 'pretender';

interface Variables {
  [field: string]: any;
}

interface ServerCallbackArgs {
  variables: Variables | null;
  calls: number;
  headers: object;
}

interface MockParams {
  response?: ServerCallback;
  errorResponse?: ServerCallback;
  expects?: ServerCallback;
}

interface ExpectCall {
  args: ServerCallbackArgs;
  expects: ServerCallback;
}

interface GraphQLBody {
  operationName: string;
  query: string;
  variables?: object;
}

const RegisteredQueries = new Map();
const RegisteredMutations = new Map();
let expectCalls: ExpectCall[] = [];

const handleGraphQLQuery = (queryBody: GraphQLBody, request: any) => {
  const queryName = queryBody.operationName;
  const map = queryBody.query.startsWith('query')
    ? RegisteredQueries
    : RegisteredMutations;

  if (map.has(queryName)) {
    const {params, calls} = map.get(queryName);
    const callbackArgs = {
      variables: queryBody.variables || null,
      calls: calls + 1,
      headers: request.requestHeaders,
    };

    map.set(queryName, {params, calls: calls + 1});

    const data = params.response(callbackArgs);
    const errors = params.errorResponse?.(callbackArgs);

    if (params.expects) {
      expectCalls.push({
        expects: params.expects,
        args: callbackArgs,
      });
    }

    return {data, errors};
  } else {
    throw new Error(`${queryName} was not found.`);
  }
};

const handleGraphQLRequest = (request: any) => {
  let parsedBody = request.requestBody && JSON.parse(request.requestBody);

  if (Array.isArray(parsedBody)) {
    return parsedBody.map((individualParsedBody: GraphQLBody) => ({
      operationName: individualParsedBody.operationName,
      payload: handleGraphQLQuery(individualParsedBody, request),
    }));
  } else {
    return handleGraphQLQuery(parsedBody as GraphQLBody, request);
  }
};

export type ServerCallback = (args: ServerCallbackArgs) => any;

export interface Server {
  pretenderServer: Pretender;
  query(queryName: string, params: ServerCallback | MockParams): void;
  getQuery(queryName: string): {calls: number};
  mutation(mutationName: string, params: ServerCallback | MockParams): void;
  getMutation(queryName: string): {calls: number};
  shutdown(): void;
}

export const setupPretender = (): Server => {
  const server: Pretender = new Pretender(function () {
    this.post('fake/endpoint/graphql', (request) => {
      const response = handleGraphQLRequest(request);

      return response
        ? [200, {'Content-Type': 'application/json'}, JSON.stringify(response)]
        : [404, {}, ''];
    });
  });

  return {
    pretenderServer: server,
    query(queryName: string, params: any) {
      if (typeof params === 'function') {
        params = {response: params};
      }

      RegisteredQueries.set(queryName, {params, calls: 0});
    },

    getQuery(queryName: string) {
      return RegisteredQueries.get(queryName);
    },

    mutation(mutationName: string, params: any) {
      if (typeof params === 'function') {
        params = {response: params};
      }

      RegisteredMutations.set(mutationName, {params, calls: 0});
    },

    getMutation(mutationName: string) {
      return RegisteredMutations.get(mutationName);
    },

    shutdown() {
      RegisteredQueries.clear();
      RegisteredMutations.clear();

      server.shutdown();

      let failedAssertion = null;

      try {
        expectCalls.forEach(({expects, args}) => expects(args));
      } catch (exception) {
        failedAssertion = exception;
      } finally {
        expectCalls = [];
      }

      if (failedAssertion) throw failedAssertion;
    },
  };
};
