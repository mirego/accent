import * as http from 'node:http';
import {AddressInfo} from 'node:net';
import {buildProject, Project} from './factory';

export interface UploadedFile {
  filename: string;
  content: string;
}

export interface RecordedRequest {
  method: string;
  path: string;
  query: Record<string, string>;
  headers: http.IncomingHttpHeaders;
  json?: any;
  form?: Record<string, string | UploadedFile>;
}

export interface MockResponse {
  status?: number;
  body?: string | object;
}

export type Handler = (
  request: RecordedRequest
) => MockResponse | Promise<MockResponse>;

export interface MockServerOptions {
  project?: Project | ((variables: Record<string, any>) => Project | null);
  fullname?: string;
  routes?: Record<string, Handler>;
}

export interface MockServer {
  url: string;
  requests: RecordedRequest[];
  requestsTo: (route: string) => RecordedRequest[];
  close: () => Promise<void>;
}

const readBody = async (request: http.IncomingMessage): Promise<Buffer> =>
  new Promise((resolve, reject) => {
    const chunks: Buffer[] = [];
    request.on('data', (chunk) => chunks.push(chunk));
    request.on('end', () => resolve(Buffer.concat(chunks)));
    request.on('error', reject);
  });

const parseForm = async (body: Buffer, contentType: string) => {
  const formData = await new Response(new Uint8Array(body), {
    headers: {'content-type': contentType}
  }).formData();
  const form: Record<string, string | UploadedFile> = {};

  for (const [name, value] of formData.entries()) {
    form[name] =
      typeof value === 'string'
        ? value
        : {filename: value.name, content: await value.text()};
  }

  return form;
};

const defaultRoutes = (options: MockServerOptions): Record<string, Handler> => {
  const project = options.project ?? buildProject();

  return {
    'POST /graphql': ({json}) => {
      const resolved =
        typeof project === 'function' ? project(json.variables) : project;
      if (!resolved) return {body: {data: null}};

      return {
        body: {
          data: {
            viewer: {
              user: {fullname: options.fullname ?? 'Jane Doe'},
              project: resolved
            }
          }
        }
      };
    },
    'GET /export': ({query}) => ({
      body: {exported: `${query.language}:${query.document_path}`}
    }),
    'GET /jipt-export': ({query}) => ({
      body: {jipt: query.document_path}
    }),
    'POST /format': () => ({body: '{"formatted": true}\n'}),
    'POST /lint': () => ({body: {data: {lint_translations: []}}}),
    'POST /sync': () => ({body: ''}),
    'POST /sync/peek': () => ({body: {data: {operations: {}, stats: {}}}}),
    'POST /add-translations': () => ({body: ''}),
    'POST /add-translations/peek': () => ({
      body: {data: {operations: {}, stats: {}}}
    })
  };
};

export const startServer = async (
  options: MockServerOptions = {}
): Promise<MockServer> => {
  const routes = {...defaultRoutes(options), ...options.routes};
  const requests: RecordedRequest[] = [];

  const handleRequest = async (
    request: http.IncomingMessage,
    response: http.ServerResponse
  ) => {
    const url = new URL(request.url!, 'http://localhost');
    const body = await readBody(request);
    const contentType = request.headers['content-type'] ?? '';

    const recorded: RecordedRequest = {
      method: request.method!,
      path: url.pathname,
      query: Object.fromEntries(url.searchParams.entries()),
      headers: request.headers
    };

    if (contentType.startsWith('application/json')) {
      recorded.json = JSON.parse(body.toString('utf8'));
    } else if (contentType.startsWith('multipart/form-data')) {
      recorded.form = await parseForm(body, contentType);
    }

    requests.push(recorded);

    const handler = routes[`${recorded.method} ${recorded.path}`];
    if (!handler) {
      response.writeHead(404).end(`No mock for ${recorded.method} ${url}`);
      return;
    }

    const {status = 200, body: responseBody = ''} = await handler(recorded);
    const isJson = typeof responseBody === 'object';

    response.writeHead(status, {
      'content-type': isJson ? 'application/json' : 'text/plain'
    });
    response.end(isJson ? JSON.stringify(responseBody) : responseBody);
  };

  const server = http.createServer((request, response) => {
    void handleRequest(request, response);
  });

  await new Promise<void>((resolve) =>
    server.listen(0, '127.0.0.1', () => resolve())
  );
  const {port} = server.address() as AddressInfo;

  return {
    url: `http://127.0.0.1:${port}`,
    requests,
    requestsTo: (route) =>
      requests.filter(({method, path}) => `${method} ${path}` === route),
    close: async () =>
      new Promise((resolve) => {
        server.closeAllConnections();
        server.close(() => resolve());
      })
  };
};
