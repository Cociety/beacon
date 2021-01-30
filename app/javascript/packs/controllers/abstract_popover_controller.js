import { Controller } from "stimulus";
export default class AbstractPopoverController extends Controller {
  static values = { id: String };

  constructor() {
    super(...arguments);
    this.subClass = new.target;
    if (new.target === AbstractPopoverController) {
      throw new TypeError("Cannot construct AbstractPopoverController instances directly");
    }
  }

  get selector() {
    throw new Error("must implement get selector()");
  }

  get srcUrl() {
    throw new Error("must implement srcUrl()");
  }

  initialize() {
    if (this.subClass.initialized) {
      return;
    }
    this.subClass.initialized = true;

    document.addEventListener('click', this.hideIfClickedOutside.bind(this));
    document.addEventListener('mousedown', this.hideIfClickedOutside.bind(this));
    document.addEventListener('keydown', this.hideIfEscapeKeyPressed.bind(this));
    window.addEventListener("resize", this.moveToClickLocationKeepingItOnScreen.bind(this));
    (new MutationObserver((mutationList) => {
      if(!this.isVisible()){
        return;
      }
      mutationList.forEach(m => {
        if(this.isTurboLinksInjection(m)) {
          this.moveToClickLocationKeepingItOnScreen();
        }
      })
    })).observe(document, {attributes: false, childList: true, subtree: true});
  }

  isTurboLinksInjection(mutation) {
    return mutation.type === "childList" && mutation.target.matches(this.selector)
  }

  moveToClickLocationKeepingItOnScreen() {
    if (!this.subClass.currentClickLocation) {
      return;
    }
    const popoverContent = this.$el.querySelector('*');
    if (!popoverContent) {
      return;
    }
    const x = Math.min(window.innerWidth - popoverContent.offsetWidth, this.subClass.currentClickLocation.x);
    const y = Math.min(window.innerHeight - popoverContent.offsetHeight, this.subClass.currentClickLocation.y);
    this.$el.style.left = `${x}px`;
    this.$el.style.top = `${y}px`;
  }

  hideIfClickedOutside(event) {
    const $elClicked = event.target.matches(`${this.selector} *, ${this.selector}`);
    if (this.isVisible() && !$elClicked) {
      this.hide();
    }
  }

  hideIfEscapeKeyPressed(event) {
    if (this.isVisible() && event.code === 'Escape' && !event.shiftKey && !event.ctrlKey) {
      this.hide();
      event.preventDefault();
    }
  }

  get $el() {
    return document.querySelector(this.selector);
  }

  isVisible() {
    return !!this.$el.innerHTML.length;
  }

  hide() {
    this.$el.innerHTML = "";
  }

  show(event) {
    event.preventDefault();
    this.subClass.currentClickLocation = {x: event.clientX, y: event.clientY };
    this.$el.setAttribute('src', this.srcUrl);
  }
}
