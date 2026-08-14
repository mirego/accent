import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import {plugin as ember} from 'eslint-plugin-ember/recommended';
import prettier from 'eslint-config-prettier';
import globals from 'globals';

const sharedTypescriptRules = {
  complexity: 0,
  'no-irregular-whitespace': 0,
  'no-unused-vars': 0,
  '@typescript-eslint/adjacent-overload-signatures': 2,
  '@typescript-eslint/array-type': [2, {default: 'array-simple'}],
  '@typescript-eslint/await-thenable': 2,
  '@typescript-eslint/consistent-type-assertions': [2, {assertionStyle: 'as'}],
  '@typescript-eslint/consistent-type-definitions': [2, 'interface'],
  '@typescript-eslint/no-empty-interface': 2,
  '@typescript-eslint/no-explicit-any': 0,
  '@typescript-eslint/no-floating-promises': 0,
  '@typescript-eslint/no-misused-new': 2,
  '@typescript-eslint/no-misused-promises': 2,
  '@typescript-eslint/parameter-properties': 2,
  '@typescript-eslint/no-require-imports': 2,
  '@typescript-eslint/no-unnecessary-type-assertion': 2,
  '@typescript-eslint/no-unused-vars': [
    2,
    {
      args: 'all',
      argsIgnorePattern: '^_',
      varsIgnorePattern: '^_',
      caughtErrors: 'none'
    }
  ],
  '@typescript-eslint/promise-function-async': 2,
  '@typescript-eslint/require-await': 2,
  '@typescript-eslint/unified-signatures': 2,
  '@typescript-eslint/no-unused-expressions': 0,
  'no-useless-assignment': 0
};

export default tseslint.config(
  {
    ignores: [
      'webapp/node_modules/**',
      'webapp/**/vendor/*.js',
      'webapp/vendor/**/*.js',
      'webapp/bower_components/**/*.js',
      'webapp/webapp-dist/**/*.js',
      'webapp/dist/**/*.js',
      'webapp/tmp/**/*.js',
      'webapp/app/locales/*/translations.js',
      'webapp/app/utils/phoenix.js',
      'cli/lib/**',
      'cli/node_modules/**',
      'cli/bin/**',
      'jipt/node_modules/**',
      'jipt/dist/**',
      'jipt/.cache/**'
    ]
  },
  {
    files: [
      'webapp/app/**/*.ts',
      'webapp/tests/**/*.ts',
      'webapp/types/**/*.ts'
    ],
    extends: [
      js.configs.recommended,
      ...tseslint.configs.recommended,
      prettier
    ],
    plugins: {ember},
    languageOptions: {
      parserOptions: {
        project: './webapp/tsconfig.json'
      },
      globals: {
        ...globals.browser,
        JsDiff: true
      }
    },
    rules: {
      ...sharedTypescriptRules,
      '@typescript-eslint/member-ordering': 0,
      '@typescript-eslint/no-non-null-assertion': 2,
      'ember/closure-actions': 2,
      'ember/named-functions-in-promises': 0,
      'ember/new-module-imports': 2,
      'ember/no-global-jquery': 2,
      'ember/no-on-calls-in-components': 2,
      'ember/no-duplicate-dependent-keys': 2,
      'ember/no-side-effects': 2,
      'ember/avoid-leaking-state-in-ember-objects': 2,
      'ember/use-brace-expansion': 2,
      'ember/jquery-ember-run': 2,
      'ember/no-empty-attrs': 2
    }
  },
  {
    files: ['cli/**/*.ts'],
    extends: [
      js.configs.recommended,
      ...tseslint.configs.recommended,
      prettier
    ],
    languageOptions: {
      parserOptions: {
        project: './cli/tsconfig.json'
      },
      globals: {
        ...globals.node,
        process: true
      }
    },
    rules: {
      ...sharedTypescriptRules,
      'no-console': 0,
      'max-nested-callbacks': [2, {max: 3}],
      '@typescript-eslint/member-ordering': 2,
      '@typescript-eslint/no-non-null-assertion': 0
    }
  },
  {
    files: ['jipt/**/*.ts'],
    extends: [
      js.configs.recommended,
      ...tseslint.configs.recommended,
      prettier
    ],
    languageOptions: {
      parserOptions: {
        project: './jipt/tsconfig.json'
      },
      globals: {
        ...globals.browser
      }
    },
    rules: {
      ...sharedTypescriptRules,
      '@typescript-eslint/member-ordering': 2,
      '@typescript-eslint/no-non-null-assertion': 2
    }
  },
  {
    files: ['webapp/app/**/*.js', 'cli/**/*.js', 'jipt/**/*.js'],
    extends: [js.configs.recommended, prettier],
    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.node
      }
    },
    rules: {
      'no-useless-assignment': 0
    }
  }
);
