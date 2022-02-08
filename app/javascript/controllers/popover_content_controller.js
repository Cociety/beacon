import { Controller } from "@hotwired/stimulus";
export default class extends Controller {

  connect() {
    document.documentElement.dispatchEvent(new Event('popover-content:connect'));
  }
}
