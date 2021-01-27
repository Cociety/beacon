import { select } from "d3";
import { delegate } from "@rails/ujs";

const anyQuickView = '[id^="quick-view-"]';

function getVisible() {
  return document.querySelectorAll(`${anyQuickView}[class*="opacity-100"]`);
}

function hideAll() {
  getVisible().forEach(menu => {
    menu.classList.add('hidden', 'opacity-0');
    setTimeout(() => {
      menu.classList.remove('opacity-100');
    });
  });
}

function show(selector, x, y) {
  hideAll();
  const element = document.querySelector(selector);
  element.style.left = `${x}px`;
  element.style.top = `${y}px`;
  element.classList.remove('hidden', 'opacity-0');
  setTimeout(() => {
    element.classList.add('opacity-100');
  });
}

function isVisible() {
  return !!getVisible().length;
}

export function clicked(event, g) {
  const svg = select(g);
  const goalId = svg.datum().data.id;
  show(`#quick-view-${goalId}`, event.clientX, event.clientY);
}

export function init() {
  delegate(document.body, '*', 'mousedown', function () {
    const quickViewClicked = this.matches(`${anyQuickView} *, ${anyQuickView}`);
    if (isVisible() && !quickViewClicked) {
      hideAll();
    }
  });
}

export default { clicked, init };
