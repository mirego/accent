import {execFileSync, spawn} from 'node:child_process';
import * as fs from 'node:fs';
import * as os from 'node:os';
import * as path from 'node:path';

const BIN = path.resolve(__dirname, '../../bin/run.js');
const ANSI_PATTERN = /\u001b\[[0-9;]*[A-Za-z]/g;

export interface CliResult {
  code: number | null;
  stdout: string;
  stderr: string;
  output: string;
}

export interface RunOptions {
  cwd: string;
  env?: Record<string, string>;
}

export const runCli = async (
  args: string[],
  {cwd, env = {}}: RunOptions
): Promise<CliResult> =>
  new Promise((resolve, reject) => {
    const inheritedEnv = {...process.env};
    delete inheritedEnv.ACCENT_API_KEY;
    delete inheritedEnv.ACCENT_API_URL;
    delete inheritedEnv.ACCENT_PROJECT;

    const child = spawn(process.execPath, [BIN, ...args], {
      cwd,
      env: {
        ...inheritedEnv,
        ACCENT_SKIP_NEW_VERSION_CHECK: 'true',
        FORCE_COLOR: '0',
        NO_COLOR: '1',
        GIT_CEILING_DIRECTORIES: path.dirname(cwd),
        ...env
      },
      stdio: ['ignore', 'pipe', 'pipe']
    });

    let stdout = '';
    let stderr = '';
    child.stdout.on('data', (chunk) => (stdout += chunk));
    child.stderr.on('data', (chunk) => (stderr += chunk));
    child.on('error', reject);
    child.on('close', (code) => {
      stdout = stdout.replace(ANSI_PATTERN, '');
      stderr = stderr.replace(ANSI_PATTERN, '');
      resolve({code, stdout, stderr, output: `${stdout}\n${stderr}`});
    });
  });

export class Workspace {
  readonly root: string;

  constructor() {
    this.root = fs.realpathSync(
      fs.mkdtempSync(path.join(os.tmpdir(), 'accent-cli-test-'))
    );
  }

  write(file: string, content: string | object) {
    const fullPath = this.path(file);
    fs.mkdirSync(path.dirname(fullPath), {recursive: true});
    fs.writeFileSync(
      fullPath,
      typeof content === 'string' ? content : JSON.stringify(content, null, 2)
    );
    return this;
  }

  writeConfig(config: object, file = 'accent.json') {
    return this.write(file, config);
  }

  read(file: string) {
    return fs.readFileSync(this.path(file), 'utf8');
  }

  exists(file: string) {
    return fs.existsSync(this.path(file));
  }

  path(file = '.') {
    return path.join(this.root, file);
  }

  gitInit(branch: string) {
    const git = (...args: string[]) =>
      execFileSync('git', args, {cwd: this.root, stdio: 'ignore'});
    git('init', '--quiet', `--initial-branch=${branch}`);
    git(
      '-c',
      'user.name=Test',
      '-c',
      'user.email=test@example.com',
      'commit',
      '--quiet',
      '--allow-empty',
      '-m',
      'init'
    );
    return this;
  }

  async run(args: string[], env?: Record<string, string>) {
    return runCli(args, {cwd: this.root, env});
  }

  cleanup() {
    fs.rmSync(this.root, {recursive: true, force: true});
  }
}
