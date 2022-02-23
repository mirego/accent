import InViewportService from 'ember-in-viewport/services/in-viewport';

type viewportCallback = () => void;

declare module 'ember-in-viewport/services/in-viewport' {
  export default class InViewport {
    watchElement(element: Element): {
      onEnter: (callback: viewportCallback) => void;
      onExit: (callback: viewportCallback) => {};
    };
    stopWatching(element: Element): void;
  }
}

declare module '@ember/service' {
  interface Registry {
    'in-viewport': InViewportService;
  }
}
