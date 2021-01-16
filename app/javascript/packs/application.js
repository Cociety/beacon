// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
import "../stylesheets/application.css"

import Rails from "@rails/ujs"
import "@hotwired/turbo-rails"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import Tree from "./tree"

Rails.start()
ActiveStorage.start()

Rails.secondLevelDomain = function(host) {
  return host.split(':')[0].split('.').slice(-2).join('.');
}

Rails.isSameSecondLevelDomain = function (originAnchor, urlAnchor) {
  return Rails.secondLevelDomain(urlAnchor.host) === Rails.secondLevelDomain(originAnchor.host);
}

Rails._isCrossDomain = Rails.isCrossDomain;
/**
 * Modified to allow matching second level domains.
 * Used by rails to determine if a url is crossDomain before it adds a CSRF token to ajax requests
 * @Override
 * @param {string} url
 */
Rails.isCrossDomain = function (url) {
  const originAnchor = document.createElement('a');
  originAnchor.href = location.href;
  const urlAnchor = document.createElement('a');
  urlAnchor.href = url;

  try {
    return !Rails.isSameSecondLevelDomain(originAnchor, urlAnchor) && Rails._isCrossDomain(url);
  } catch {
    // any errors assume cross domain, just like original method
    return true;
  }
}

class DragAndDrop {
  dragging = false;

  dragStartHandler = function(event) {
    event.dataTransfer.setData("text/plain", event.target.id);
    event.dataTransfer.dropEffect = "move";
    this.dragging = true;
  }

  dragOverHandler = function(event) {
    event.preventDefault();
    event.dataTransfer.dropEffect = "move";
  }

  dropHandler = function(event) {
    event.preventDefault();
    const childId = event.dataTransfer.getData("text/plain");
    if (this.dragging) {
      const child = document.getElementById(childId);
      const newParent = event.currentTarget;
      newParent.querySelector('ul').appendChild(child);
      this.dragging = false;
      app.moveTo(child.dataset.id, newParent.dataset.id);
    }
    return false;
  }
}

class App {
  moveTo = async function(goal_id, new_parent_id) {
    Rails.ajax({
      url: `/goals/${encodeURIComponent(goal_id)}/move_to/${encodeURIComponent(new_parent_id)}`,
      type: 'PUT'
    });
  }
}
window.app = new App();


window.DaD = new DragAndDrop();

document.addEventListener('DOMContentLoaded', () => {
  const content = document.getElementById("content");
  const tree = new Tree(JSON.parse(content.dataset.goal), { width: content.offsetWidth, height: 600, nodeRadius: 40 });
  tree.draw();
})
