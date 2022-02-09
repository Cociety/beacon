var e={};(function(t,l){l(e)})(e,(function(e){function isTopLevelEl(e){return e===document.body||e===document.documentElement}function getElementViewportOffset(e,t){var l;if(isTopLevelEl(e))l=0===t?e.clientLeft:e.clientTop;else{var r=e.getBoundingClientRect();l=0===t?r.left:r.top}return l}function getElementViewportSize(e,t){var l;l=isTopLevelEl(e)?0===t?window.innerWidth:window.innerHeight:0===t?e.clientWidth:e.clientHeight;return l}function getSetElementScroll(e,t,l){var r=0===t?"scrollLeft":"scrollTop";var n=isTopLevelEl(e);if(2===arguments.length)return n?document.body[r]||document.documentElement[r]:e[r];if(n){document.documentElement[r]+=l;document.body[r]+=l}else e[r]+=l}function isScrollable(e){var t=getComputedStyle(e);return e.scrollHeight>e.clientHeight&&("scroll"===t.overflowY||"auto"===t.overflowY)||e.scrollWidth>e.clientWidth&&("scroll"===t.overflowX||"auto"===t.overflowX)}function findScrollableParent(e){do{if(!e)return;if(isScrollable(e))return e;if(e===document.documentElement)return null}while(e=e.parentNode);return null}function determineScrollIntention(e,t,l){return e<l?-1:t-e<l?1:0}function determineDynamicVelocity(e,t,l,r){return-1===e?Math.abs(t-r):1===e?Math.abs(l-t-r):0}function isScrollEndReached(e,t,l){var r=0===e?l.scrollX:l.scrollY;if(1===t){var n=0===e?l.scrollWidth-l.width:l.scrollHeight-l.height;return r>=n}return-1!==t||r<=0}var t={threshold:75,velocityFn:function(e,t){var l=e/t;var r=l*l*l;return r*t}};var l={horizontal:0,vertical:0};var r={x:0,y:0};var n;var o;var i;var c;var a;function handleDragImageTranslateOverride(e,d,u,h){o=d;a=h;if(i!==u){i=u;c=findScrollableParent(i)}var s=updateScrollIntentions(o,c,t.threshold,l,r);if(s)scheduleScrollAnimation();else if(!!n){window.cancelAnimationFrame(n);n=null}}function scheduleScrollAnimation(){n||(n=window.requestAnimationFrame(scrollAnimation))}function scrollAnimation(){var e=0,i=0,d=isTopLevelEl(c);if(0!==l.horizontal){e=Math.round(t.velocityFn(r.x,t.threshold)*l.horizontal);getSetElementScroll(c,0,e)}if(0!==l.vertical){i=Math.round(t.velocityFn(r.y,t.threshold)*l.vertical);getSetElementScroll(c,1,i)}d?a(e,i):a(0,0);n=null;updateScrollIntentions(o,c,t.threshold,l,r)&&scheduleScrollAnimation()}function updateScrollIntentions(e,t,l,r,n){if(!e||!t)return false;var o={x:getElementViewportOffset(t,0),y:getElementViewportOffset(t,1),width:getElementViewportSize(t,0),height:getElementViewportSize(t,1),scrollX:getSetElementScroll(t,0),scrollY:getSetElementScroll(t,1),scrollWidth:t.scrollWidth,scrollHeight:t.scrollHeight};var i={x:e.x-o.x,y:e.y-o.y};r.horizontal=determineScrollIntention(i.x,o.width,l);r.vertical=determineScrollIntention(i.y,o.height,l);r.horizontal&&isScrollEndReached(0,r.horizontal,o)?r.horizontal=0:r.horizontal&&(n.x=determineDynamicVelocity(r.horizontal,i.x,o.width,l));r.vertical&&isScrollEndReached(1,r.vertical,o)?r.vertical=0:r.vertical&&(n.y=determineDynamicVelocity(r.vertical,i.y,o.height,l));return!!(r.horizontal||r.vertical)}var d=handleDragImageTranslateOverride;e.scrollBehaviourDragImageTranslateOverride=d;Object.defineProperty(e,"__esModule",{value:true})}));const t=e.scrollBehaviourDragImageTranslateOverride,l=e.__esModule;export default e;export{l as __esModule,t as scrollBehaviourDragImageTranslateOverride};
