import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  submit(e) {
    // 'Rails.fire' in Stimulus controller not working with Rails 6.1 defaults
    // https://discuss.hotwired.dev/t/rails-fire-in-stimulus-controller-not-working-with-rails-6-1-defaults/1957
    // fire(this.element, submit) requires remote=true on the form for rails to submit with ajax, otherwise this ignores it
    // having that as a requirement for this to work seems silly
    e.preventDefault();
    this.element.submit();
  }
}
