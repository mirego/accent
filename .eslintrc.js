module.exports = {
  root: true,
  overrides: [
    {
      files: ['webapp/app/**/*', 'webapp/tests/**/*', 'webapp/types/**/*'],
      parser: '@typescript-eslint/parser',
      parserOptions: {
        project: './webapp/tsconfig.json'
      },
      plugins: ['@typescript-eslint', 'ember', 'mirego'],
      extends: [
        'plugin:mirego/recommended',
        'prettier',
        'prettier/@typescript-eslint',
        'typestrict'
      ],
      env: {
        es6: true,
        browser: true
      },
      globals: {
        JsDiff: true
      },
      rules: {
        'complexity': 0,
        'no-irregular-whitespace': 0,
        'ember/closure-actions': 2,
        'ember/named-functions-in-promises': 0,
        'ember/new-module-imports': 2,
        'ember/no-global-jquery': 2,
        'ember/no-on-calls-in-components': 2,
        'ember/no-duplicate-dependent-keys': 2,
        'ember/no-side-effects': 2,
        'ember/require-super-in-init': 2,
        'ember/avoid-leaking-state-in-ember-objects': 2,
        'ember/use-brace-expansion': 2,
        'ember/jquery-ember-run': 2,
        'ember/order-in-routes': 2,
        'ember/order-in-controllers': 2,
        'ember/no-empty-attrs': 2,
        '@typescript-eslint/adjacent-overload-signatures': 2,
        '@typescript-eslint/array-type': [2, {default: 'array-simple'}],
        '@typescript-eslint/await-thenable': 2,
        '@typescript-eslint/ban-ts-ignore': 2,
        '@typescript-eslint/consistent-type-assertions': [
          2,
          {assertionStyle: 'as'}
        ],
        '@typescript-eslint/consistent-type-definitions': [2, 'interface'],
        '@typescript-eslint/member-delimiter-style': [
          2,
          {
            multiline: {
              delimiter: 'semi',
              requireLast: true
            },
            singleline: {
              delimiter: 'semi',
              requireLast: false
            }
          }
        ],
        '@typescript-eslint/member-ordering': 2,
        '@typescript-eslint/no-empty-interface': 2,
        '@typescript-eslint/no-floating-promises': 2,
        '@typescript-eslint/no-misused-new': 2,
        '@typescript-eslint/no-misused-promises': 2,
        '@typescript-eslint/no-non-null-assertion': 2,
        '@typescript-eslint/no-parameter-properties': 2,
        '@typescript-eslint/no-require-imports': 2,
        '@typescript-eslint/no-unnecessary-type-assertion': 2,
        '@typescript-eslint/promise-function-async': 2,
        '@typescript-eslint/require-await': 2,
        '@typescript-eslint/type-annotation-spacing': 2,
        '@typescript-eslint/unified-signatures': 2,
        'no-unused-vars': 0,
        'no-invalid-this': 0,
        '@typescript-eslint/no-unused-vars': 2,
      }
    },
    {
      files: [
        'webapp/.ember-cli.js',
        'webapp/.eslintrc.js',
        'webapp/.template-lintrc.js',
        'webapp/ember-cli-build.js',
        'webapp/testem.js',
        'webapp/config/**/*.js',
        'webapp/lib/*/index.js',
        'webapp/scripts/**/*.js',
        'webapp/node-server/**/*.js'
      ],
      parserOptions: {
        sourceType: 'script',
        ecmaVersion: 2015
      },
      env: {
        browser: false,
        node: true
      },
      plugins: ['node'],
      rules: {
        '@typescript-eslint/no-require-imports': 0,

        // this can be removed once the following is fixed
        // https://github.com/mysticatea/eslint-plugin-node/issues/77
        'node/no-unpublished-require': 'off'
      },
      extends: ['plugin:node/recommended']
    },
    {
      files: ['cli/**/*'],
      env: {
        es6: true
      },
      globals: {
        process: true
      },
      parser: '@typescript-eslint/parser',
      parserOptions: {
        project: './cli/tsconfig.json'
      },
      plugins: ['@typescript-eslint', 'mirego'],
      extends: [
        'plugin:mirego/recommended',
        'prettier',
        'prettier/@typescript-eslint'
      ],
      rules: {
        'complexity': 0,
        'no-irregular-whitespace': 0,
        'no-unused-vars': 0,
        'no-console': 0,
        'max-nested-callbacks': [2, {max: 3}],
        '@typescript-eslint/adjacent-overload-signatures': 2,
        '@typescript-eslint/array-type': [2, {default: 'array-simple'}],
        '@typescript-eslint/await-thenable': 2,
        '@typescript-eslint/ban-ts-ignore': 2,
        '@typescript-eslint/consistent-type-assertions': [
          2,
          {assertionStyle: 'as'}
        ],
        '@typescript-eslint/consistent-type-definitions': [2, 'interface'],
        '@typescript-eslint/member-delimiter-style': [
          2,
          {
            multiline: {
              delimiter: 'semi',
              requireLast: true
            },
            singleline: {
              delimiter: 'semi',
              requireLast: false
            }
          }
        ],
        '@typescript-eslint/member-ordering': 2,
        '@typescript-eslint/no-empty-interface': 2,
        '@typescript-eslint/no-floating-promises': 2,
        '@typescript-eslint/no-misused-new': 2,
        '@typescript-eslint/no-misused-promises': 2,
        '@typescript-eslint/no-non-null-assertion': 0,
        '@typescript-eslint/no-parameter-properties': 2,
        '@typescript-eslint/no-require-imports': 2,
        '@typescript-eslint/no-unnecessary-type-assertion': 2,
        '@typescript-eslint/promise-function-async': 2,
        '@typescript-eslint/require-await': 2,
        '@typescript-eslint/type-annotation-spacing': 2,
        '@typescript-eslint/unified-signatures': 2,
        '@typescript-eslint/no-unused-vars': 2
      }
    },
    {
      files: ['jipt/**/*'],
      env: {
        es6: true
      },
      parser: '@typescript-eslint/parser',
      parserOptions: {
        project: './jipt/tsconfig.json'
      },
      plugins: ['@typescript-eslint', 'mirego'],
      extends: [
        'plugin:mirego/recommended',
        'prettier',
        'prettier/@typescript-eslint'
      ],
      rules: {
        'complexity': 0,
        'no-irregular-whitespace': 0,
        'no-unused-vars': 0,
        '@typescript-eslint/adjacent-overload-signatures': 2,
        '@typescript-eslint/array-type': [2, {default: 'array-simple'}],
        '@typescript-eslint/await-thenable': 2,
        '@typescript-eslint/ban-ts-ignore': 2,
        '@typescript-eslint/consistent-type-assertions': [
          2,
          {assertionStyle: 'as'}
        ],
        '@typescript-eslint/consistent-type-definitions': [2, 'interface'],
        '@typescript-eslint/member-delimiter-style': [
          2,
          {
            multiline: {
              delimiter: 'semi',
              requireLast: true
            },
            singleline: {
              delimiter: 'semi',
              requireLast: false
            }
          }
        ],
        '@typescript-eslint/member-ordering': 2,
        '@typescript-eslint/no-empty-interface': 2,
        '@typescript-eslint/no-floating-promises': 2,
        '@typescript-eslint/no-misused-new': 2,
        '@typescript-eslint/no-misused-promises': 2,
        '@typescript-eslint/no-non-null-assertion': 2,
        '@typescript-eslint/no-parameter-properties': 2,
        '@typescript-eslint/no-require-imports': 2,
        '@typescript-eslint/no-unnecessary-type-assertion': 2,
        '@typescript-eslint/promise-function-async': 2,
        '@typescript-eslint/require-await': 2,
        '@typescript-eslint/type-annotation-spacing': 2,
        '@typescript-eslint/unified-signatures': 2,
        '@typescript-eslint/no-unused-vars': 2
      }
    }
  ]
};
