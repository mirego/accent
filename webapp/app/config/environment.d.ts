/**
 * Type declarations for
 *    import config from './config/environment'
 *
 * For now these need to be managed by the developer
 * since different ember addons can materialize new entries.
 */
declare const config: {
  environment: any;
  modulePrefix: string;
  podModulePrefix: string;
  locationType: string;
  rootURL: string;
  version: string;

  EmberENV: {
    EXTEND_PROTOTYPES: boolean;
    LOG_VERSION: boolean;
  };

  APP: {
    LOCAL_STORAGE: {
      SESSION_NAMESPACE: string;
    };
  };

  API: {
    WS_HOST: string;
    WS_ENABLED: boolean;
    HOST: string;
    AUTHENTICATION_PATH: string;
    HOOKS_PATH: string;
    PROJECT_PATH: string;
    SYNC_PEEK_PROJECT_PATH: string;
    SYNC_PROJECT_PATH: string;
    MERGE_PEEK_PROJECT_PATH: string;
    MERGE_REVISION_PATH: string;
    EXPORT_DOCUMENT: string;
    JIPT_EXPORT_DOCUMENT: string;
    PERCENTAGE_REVIEWED_BADGE_SVG_PROJECT_PATH: string;
    JIPT_SCRIPT_PATH: string;
  };

  SENTRY: {
    DSN: string;
  };

  contentSecurityPolicy: {
    'default-src': string | string[];
    'script-src': string | string[];
    'font-src': string | string[];
    'connect-src': string | string[];
    'img-src': string | string[];
    'style-src': string | string[];
    'media-src': string | string[];
    'frame-src': string | string[];
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
};

export default config;
