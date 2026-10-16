import {afterEach} from 'node:test';
import {Workspace} from './cli';
import {MockServer, MockServerOptions, startServer} from './server';

export const API_KEY = 'test-api-key';
export const PROJECT_ID = 'project-id';

const cleanups: Array<() => Promise<void> | void> = [];

afterEach(async () => {
  while (cleanups.length) await cleanups.pop()!();
});

export const setup = async (options: MockServerOptions = {}) => {
  const server = await startServer(options);
  const workspace = new Workspace();

  cleanups.push(async () => server.close());
  cleanups.push(() => workspace.cleanup());

  const config = (attributes: object = {}) => ({
    apiUrl: server.url,
    apiKey: API_KEY,
    project: PROJECT_ID,
    ...attributes
  });

  return {server, workspace, config};
};

export {MockServer};
