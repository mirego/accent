import LiveNode from '../mutation/live-node';
import State from '../state';
import styles from './styles';
import UI from './ui';

interface Props {
  ui: UI;
  liveNode: LiveNode;
  root: Element;
  state: State;
}

const CENTER_OFFSET = 6;

/*
  The Pin component serves as the entrypoint for the user. The element it creates
  is responsible to sending messages to the Accent UI.
*/
export default class Pin {
  private readonly element: Element;
  private readonly liveNode: LiveNode;
  private readonly state: State;
  private readonly ui: UI;

  constructor(props: Props) {
    this.state = props.state;
    this.liveNode = props.liveNode;
    this.ui = props.ui;

    const pin = document.createElement('div');
    styles.hide(pin);

    props.root.append(pin);

    this.element = pin;
  }

  bindEvents() {
    this.element.addEventListener('click', (event) => {
      const target = event.target as HTMLElement;

      if (target.dataset.id) {
        this.ui.selectTranslation(target.dataset.id);
        styles.hide(this.element);
      }
      if (target.dataset.ids) {
        this.ui.selectTranslations(target.dataset.ids);
        styles.hide(this.element);
      }
    });

    document.addEventListener('mouseover', (event) => {
      const node = event.target as HTMLElement;

      if (this.liveNode.isLive(node)) this.showFor(node);
    });
  }

  private showFor(target: HTMLElement) {
    const {left, top, height} = target.getBoundingClientRect();
    const keys: string[] = Array.from(
      this.state.nodes.get(target).keys.values()
    );
    styles.set(
      this.element,
      `top: ${top + height - CENTER_OFFSET}px; left: ${
        left - CENTER_OFFSET
      }px; ${styles.pin}`
    );

    const ids = keys
      .map((key: string) => this.state.projectTranslations[key].id)
      .filter(Boolean)
      .join(',');

    this.element.innerHTML = this.pinContent(
      `data-id${keys.length > 1 ? 's' : ''}="${ids}"`
    );
  }

  private pinContent(id) {
    return `
       <div ${id} style="${styles.pinIcon}">
         <svg ${id} width="20px" height="20px" viewBox="0 0 36 36">
             <g ${id} stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
               <circle ${id} fill="#3DBC87" cx="18" cy="18" r="18"></circle>
               <path ${id} d="M14.1696451,26.1250371 L11.1975445,26.7239617 L11.1975445,26.7239617 C10.6561431,26.8330625 10.1288069,26.4826137 10.0197061,25.9412123 C9.99341156,25.8107285 9.99343152,25.6763082 10.0197648,25.5458323 L10.6195235,22.5741487 L10.6195235,22.5741487 C10.7287851,22.0327797 11.2562253,21.6824875 11.7975943,21.791749 C11.990561,21.8306944 12.1677406,21.9257281 12.3069277,22.0649396 L14.6792696,24.4376986 L14.6792696,24.4376986 C15.0697595,24.8282572 15.0697039,25.4614222 14.6791453,25.8519122 C14.5399046,25.9911284 14.3626638,26.0861409 14.1696451,26.1250371 Z M13.0837185,20.8347429 L15.9160431,23.6675654 L15.9159809,23.6676275 C16.3064709,24.0581861 16.9396358,24.0582418 17.3301945,23.6677518 C17.3302152,23.6677311 17.3302359,23.6677104 17.3302566,23.6676897 L27.4577455,13.5400764 L27.4577455,13.5400764 C27.8482698,13.1495521 27.8482698,12.5163872 27.4577455,12.1258629 L24.6247987,9.29291609 L24.6248216,9.29289322 C24.2342973,8.90236893 23.6011323,8.90236893 23.2106081,9.29289322 C23.2106004,9.29290084 23.2105928,9.29290847 23.2105852,9.29291609 L13.0837578,19.4204443 L13.0838428,19.4205293 C12.6933644,19.811033 12.6933468,20.4441324 13.0838035,20.8346579 Z" fill="#FFFFFF" fill-rule="nonzero"></path>
             </g>
         </svg>
       </div>
    `;
  }
}
