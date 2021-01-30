import { Controller } from "stimulus";
import { delegate } from "@rails/ujs";
export default class QuickViewController extends Controller {
  static values = { id: String };

  initialize() {
    if (QuickViewController.initialized) {
      return;
    }
    QuickViewController.initialized = true;

    const self = this;
    delegate(document.body, '*', 'mousedown', function () {
      const quickViewClicked = this.matches(`#quick_view *, #quick_view`);
      if (self.isVisible() && !quickViewClicked) {
        self.hide();
      }
    });
  }

  quickView() {
    return document.getElementById('quick_view');
  }

  isVisible() {
    return !!this.quickView().innerHTML.length;
  }

  hide() {
    this.quickView().innerHTML = "";
  }

  show(event) {
    this.quickView().setAttribute('src', `/goals/${encodeURIComponent(this.idValue)}/quick_view`);
    this.quickView().style.left = `${event.clientX}px`;
    this.quickView().style.top = `${event.clientY}px`;
  }
}
