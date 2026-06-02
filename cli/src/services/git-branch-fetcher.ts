import {execSync} from 'child_process';

export const getCurrentBranchName = (): string => {
  try {
    return execSync('git rev-parse --abbrev-ref HEAD')
      .toString('utf8')
      .replace(/[\n\r\s]+$/, '');
  } catch {
    return '';
  }
};
