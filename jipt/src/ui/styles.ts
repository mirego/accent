/* Inline styles are used everywhere so that it does not conflict with parent window styles */

const set = (element: Element, style: string) =>
  element.setAttribute('style', style);
const hide = (element: Element) => set(element, 'display: none;');

// Pin
const pin = 'position: fixed; z-index: 10000; min-width: 150px;';
const pinList =
  'color: #fff; cursor: pointer; margin: 0; padding: 5px; list-style: none; background: hsl(158, 74%, 46%); font-family: -apple-system, BlinkMacSystemFont, Helvetica, Arial, sans-serif; line-height: 1.5; font-size: 12px;';
const pinIcon =
  'box-sizing: border-box; width: 18px; height: 18px; cursor: pointer;';

// Node
const translationNode =
  'outline: 1px #b3e4d2 solid; outline-offset: -1px;transition: outline-color 0.2s ease-in-out;';
const translationNodeConflicted =
  'outline: 1px #1ecc8c solid; outline-offset: -1px;transition: outline-color 0.2s ease-in-out;';
const translationNodeUpdated =
  'outline: 1px #c8f5e4 solid; outline-offset: -1px;transition: outline-color 0.2s ease-in-out;';

// Frame
const frameBase =
  'position: fixed; z-index: 10001; bottom: 0; right: 10px; background: #fff; box-shadow: 0 3px 20px rgba(0, 0, 0, 0.3); transition: transform 0.2s ease-in-out;';
const frameCollapsed = `${frameBase} transform: translate3d(0, 558px, 0);`;
const frameExpanded = `${frameBase} transform: translate3d(0, 0, 0);`;
const frameCentered =
  'position: fixed; z-index: 10003; top: calc(50% - 300px); right: calc(50% - 300px); background: #fff; box-shadow: 0 3px 20px rgba(0, 0, 0, 0.3);';
const frameCollapseButton =
  'cursor: pointer; position: absolute; right: 4px; top: 2px; width: 24px; height: 24px; text-align: center; color: #555; font-size: 20px;';
const frameExpandButton =
  'cursor: pointer; position: absolute; left: 0; top: 0; width: 100%; height: 400px; text-align: center; color: #555; font-size: 20px;';
const frameDisableButton =
  'cursor: pointer; position: absolute; right: 4px; top: 2px; width: 24px; height: 24px; text-align: center; color: #555; font-size: 20px;';
const overlay =
  'position: fixed; z-index: 10002; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0, 0, 0, 0.8)';
const frameWindow = 'width: 600px; height: 600px';

export default {
  frameCentered,
  frameCollapseButton,
  frameCollapsed,
  frameDisableButton,
  frameExpandButton,
  frameExpanded,
  frameWindow,
  hide,
  overlay,
  pin,
  pinIcon,
  pinList,
  set,
  translationNode,
  translationNodeConflicted,
  translationNodeUpdated,
};
