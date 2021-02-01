import { Controller } from "stimulus";
export default class extends Controller {

  connect() {
    document.documentElement.dispatchEvent(new Event('popover-content:connect'));
  }
}
