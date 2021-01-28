import { select } from "d3";
import { delegate } from "@rails/ujs";

const anyContextMenu = '[id^="context-menu-"]';

function getVisible() {
  return document.querySelectorAll(`${anyContextMenu}[class*="opacity-100"]`);
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

export function handler(event) {
  event.preventDefault();
  const circle = select(this);
  const goalId = circle.datum().data.id;
  show(`#context-menu-${goalId}`, event.clientX, event.clientY);
}

export function init() {
  // close context menu when clicking outside of it or pressing escape
  delegate(document.body, '*', 'mousedown', function () {
    const contextMenuClicked = this.matches(`${anyContextMenu} *, ${anyContextMenu}`);
    if (isVisible() && !contextMenuClicked) {
      hideAll();
    }
  });

  // close context menu when pressing escape key
  delegate(document.body, '*', 'keydown', (e) => {
    if (isVisible() && e.code === 'Escape' && !e.shiftKey && !e.ctrlKey) {
      hideAll();
      return false;
    }
  });
}

export default { handler, init };
