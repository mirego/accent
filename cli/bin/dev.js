#!/usr/bin/env -S npx ts-node --esm

// eslint-disable-next-line unicorn/prefer-top-level-await
(async () => {
  const oclif = await import('@oclif/core');
  await oclif.execute({development: true, dir: import.meta.url});
})();
