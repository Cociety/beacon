import { Controller } from "stimulus";
import { fire } from "@rails/ujs"

export default class extends Controller {
  submit() {
    fire(this.element, 'submit');
  }
}
