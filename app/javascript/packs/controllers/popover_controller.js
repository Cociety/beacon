import { Controller } from "stimulus";

export default class extends Controller {
  initialize() {
    document.documentElement.addEventListener('popover-content:connect', this.moveIfOffScreen);
    window.addEventListener('resize', this.moveIfOffScreen);
  }

  get popover() {
    return document.getElementById('popover');
  }

  moveToClickPoint(event) {
    if (this.isPopoverTriggerClick(event)) {
      this.clickXY = { x: event.clientX, y: event.clientY };
      this.popoverXY = this.clickXY;
    }
  }

  isPopoverTriggerClick(event) {
    return event.target.dataset.turboFrame === "popover";
  }

  set popoverXY(xy) {
    this.popover.style.left = `${xy.x}px`;
    this.popover.style.top = `${xy.y}px`;
  }

  moveIfOffScreen = () => {
    this.popoverXY = {
      x: Math.min(window.innerWidth - this.popover.offsetWidth, this.clickXY.x),
      y: Math.min(window.innerHeight - this.popover.offsetHeight, this.clickXY.y)
    };
  }

  hide() {
    this.popover.innerHTML = "";
  }

  hideIfClickedOutside(event) {
    const popoverClicked = event.target.matches(`#popover *, #popover`);
    if (!popoverClicked) {
      this.hide();
    }
  }

  hideIfEscapeKeyPressed(event) {
    if (event.code === 'Escape' && !event.shiftKey && !event.ctrlKey) {
      event.preventDefault();
      this.hide();
    }
  }
}
