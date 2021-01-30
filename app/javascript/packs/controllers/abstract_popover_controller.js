import { Controller } from "stimulus";
export default class AbstractPopoverController extends Controller {
  static values = { id: String };

  constructor() {
    super(...arguments);
    this.newTarget = new.target;
    if (new.target === AbstractPopoverController) {
      throw new TypeError("Cannot construct Abstract instances directly");
    }
  }

  get selector() {
    throw new Error("must implement get selector()");
  }

  get srcUrl() {
    throw new Error("must implement srcUrl()");
  }

  initialize() {
    if (this.newTarget.initialized) {
      return;
    }
    this.newTarget.initialized = true;

    document.addEventListener('click', this.hideIfClickedOutside.bind(this));
    document.addEventListener('mousedown', this.hideIfClickedOutside.bind(this));
    document.addEventListener('keydown', this.hideIfEscapeKeyPressed.bind(this));
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
    this.$el.setAttribute('src', this.srcUrl);
    this.$el.style.left = `${event.clientX}px`;
    this.$el.style.top = `${event.clientY}px`;
  }
}
