import FrameListener from './frame-listener.ts';
import LiveNode from './mutation/live-node.ts';
import Mutation from './mutation/mutation.ts';
import State from './state.ts';
import Pin from './ui/pin.ts';
import UI from './ui/ui.ts';

export interface Config {
  i: string; // Project’s ID
  h: string; // Accent API’s URL
  o: boolean; // Hide black screen overlay on script loading, default: false
}

const state = new State();

const liveNode = new LiveNode(state);

/*
  Entrypoint of the application.

  Sets frame listener, mutation and UI.
*/
export const Accent = {
  init: (config: Config) => {
    const root = document.body;

    const ui = new UI({root, config, state});
    ui.bindEvents();

    const frameListener = new FrameListener({ui, liveNode, config, state});
    frameListener.bindEvents();

    const pin = new Pin({root, liveNode, state, ui});
    pin.bindEvents();

    const mutation = new Mutation(liveNode);
    mutation.bindEvents();
  }
};

export default Accent;
