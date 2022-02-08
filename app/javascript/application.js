// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import Rails from "@rails/ujs"

import * as ActiveStorage from "@rails/activestorage"
import MobileDragDrop from "mobile-drag-drop";

// // optional import of scroll behaviour
import ScrollBehavior from "mobile-drag-drop/scroll-behaviour";

// // options are optional ;)
MobileDragDrop.polyfill({
    // use this to make use of the scroll behaviour
    dragImageTranslateOverride: ScrollBehavior.scrollBehaviourDragImageTranslateOverride
});

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
