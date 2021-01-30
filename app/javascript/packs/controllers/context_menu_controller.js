import { Controller } from "stimulus";
import { delegate } from "@rails/ujs";
export default class ContextMenuController extends Controller {
  static values = { id: String };

  initialize() {
    if (ContextMenuController.initialized) {
      return;
    }
    ContextMenuController.initialized = true;

    const self = this;
    delegate(document.body, '*', 'mousedown', function () {
      const contextMenuClicked = this.matches(`#context_menu *, #context_menu`);
      if (self.isVisible() && !contextMenuClicked) {
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

  contextMenu() {
    return document.getElementById('context_menu');
  }

  isVisible() {
    return !!this.contextMenu().innerHTML.length;
  }

  hide() {
    this.contextMenu().innerHTML = "";
  }

  show(event) {
    event.preventDefault();
    this.contextMenu().setAttribute('src', `/goals/${encodeURIComponent(this.idValue)}/context_menu`);
    this.contextMenu().style.left = `${event.clientX}px`;
    this.contextMenu().style.top = `${event.clientY}px`;
  }
}
