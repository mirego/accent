import {dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {babelCompatSupport} from '@embroider/compat/babel';
import {scopedCSS} from 'ember-scoped-css/babel';

export default {
  plugins: [
    'ember-concurrency/async-arrow-task-transform',
    scopedCSS(),
    [
      '@babel/plugin-transform-typescript',
      {
        allExtensions: true,
        onlyRemoveTypeImports: false,
        allowDeclareFields: true,
      },
    ],
    [
      'babel-plugin-ember-template-compilation',
      {
        transforms: [scopedCSS.template({})],
      },
    ],
    [
      'module:decorator-transforms',
      {
        runtime: {
          import: fileURLToPath(
            import.meta.resolve('decorator-transforms/runtime-esm')
          ),
        },
      },
    ],
    [
      '@babel/plugin-transform-runtime',
      {
        absoluteRuntime: dirname(fileURLToPath(import.meta.url)),
        useESModules: true,
        regenerator: false,
      },
    ],
    ...babelCompatSupport(),
  ],

  generatorOpts: {
    compact: false,
  },
};
