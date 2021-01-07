// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

Rails.start()
Turbolinks.start()
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
