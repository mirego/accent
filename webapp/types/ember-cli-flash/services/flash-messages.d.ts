import FlashMessages from 'ember-cli-flash/services/flash-messages';

declare module 'ember-cli-flash/services/flash-messages' {
  interface FlashOptions {
    timeout?: number;
    sticky?: boolean;
    extendedTimeout?: number;
    destroyOnClick?: boolean;
    onDestroy?: () => void;
  }

  export default class FlashMessages {
    success(message: string, options?: FlashOptions): void;
    warning(message: string, options?: FlashOptions): void;
    info(message: string, options?: FlashOptions): void;
    danger(message: string, options?: FlashOptions): void;
  }
}

declare module '@ember/service' {
  interface Registry {
    'flash-messages': FlashMessages;
  }
}
