import { Controller } from "@hotwired/stimulus";

export default class FlashController extends Controller {

  static HIDE_CLASSES = ['opacity-0', 'scale-90'];

  initialize() {
    this.hide();
  }

  connect() {
    setTimeout(() => {
      this.element.classList.add('transition-all','ease-in');
      this.show();
    }, 0);
    setTimeout(this.hide.bind(this), 5000);
  }

  hide() {
    this.element.classList.add(...FlashController.HIDE_CLASSES);
  }

  show() {
    this.element.classList.remove(...FlashController.HIDE_CLASSES);
  }
}
