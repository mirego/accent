import loadConfigFromMeta from '@embroider/config-meta-loader';
import { assert } from '@ember/debug';

const config = loadConfigFromMeta('accent-webapp') as unknown;

assert(
  'config is not an object',
  typeof config === 'object' && config !== null,
);
assert(
  'modulePrefix was not detected on your config',
  'modulePrefix' in config && typeof config.modulePrefix === 'string',
);
assert(
  'locationType was not detected on your config',
  'locationType' in config && typeof config.locationType === 'string',
);
assert(
  'rootURL was not detected on your config',
  'rootURL' in config && typeof config.rootURL === 'string',
);
assert(
  'APP was not detected on your config',
  'APP' in config && typeof config.APP === 'object',
);

export default config as {
  environment: string;
  modulePrefix: string;
  podModulePrefix?: string;
  locationType: string;
  rootURL: string;
  version: string;
  EmberENV: {
    EXTEND_PROTOTYPES: boolean;
    LOG_VERSION: boolean;
  };
  API: {
    HOST?: string;
    AUTHENTICATION_PATH: string;
    HOOKS_PATH: string;
    PROJECT_PATH: string;
    MACHINE_TRANSLATIONS_TRANSLATE_FILE_PROJECT_PATH: string;
    MACHINE_TRANSLATIONS_TRANSLATE_DOCUMENT_PROJECT_PATH: string;
    SYNC_PEEK_PROJECT_PATH: string;
    SYNC_PROJECT_PATH: string;
    MERGE_PEEK_PROJECT_PATH: string;
    MERGE_REVISION_PATH: string;
    EXPORT_DOCUMENT: string;
    JIPT_EXPORT_DOCUMENT: string;
    PERCENTAGE_REVIEWED_BADGE_SVG_PROJECT_PATH: string;
    REVIEWED_BADGE_SVG_PROJECT_PATH: string;
    TRANSLATIONS_BADGE_SVG_PROJECT_PATH: string;
    CONFLICTS_BADGE_SVG_PROJECT_PATH: string;
    JIPT_SCRIPT_PATH: string;
  };
  SENTRY: {
    DSN: string;
  };
  APP: {
    rootElement?: string;
  };
  flashMessageDefaults: {
    timeout: number;
    destroyOnClick: boolean;
    extendedTimeout: number;
    priority: number;
    sticky: boolean;
    showProgress: boolean;
    type: string;
    types: string[];
    injectionFactories: [];
  };
} & Record<string, unknown>;
