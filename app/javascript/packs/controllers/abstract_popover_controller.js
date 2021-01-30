import { Controller } from "stimulus";
import { delegate } from "@rails/ujs";
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

    const self = this;
    delegate(document.body, '*', 'mousedown', function () {
      const $elClicked = this.matches(`${self.selector} *, ${self.selector}`);
      if (self.isVisible() && !$elClicked) {
        self.hide();
      }
    });

    delegate(document.body, '*', 'keydown', (e) => {
      if (self.isVisible() && e.code === 'Escape' && !e.shiftKey && !e.ctrlKey) {
        self.hide();
        return false;
      }
    });
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
