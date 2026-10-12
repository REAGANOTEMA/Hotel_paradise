/*
 * A shared, staggered shake for every button in the management suite.
 *
 * The same gentle three second ripple as the public site. One controller hands
 * each eligible control its own point in the cycle, so a table of buttons
 * breathes in a slow wave rather than pulsing together. The animation lives in
 * admin.css and only ever moves `translate` and `rotate`, which sit apart from
 * the `transform` a hover or press already uses, so no button's size, place,
 * colour or behaviour changes.
 *
 * Buttons drawn later - a table refreshed over the network, a modal, a panel -
 * are caught by one MutationObserver, only controls near the viewport animate,
 * and anyone who asked for reduced motion is left entirely alone.
 */
(function () {
  'use strict';

  var ELIGIBLE = 'button,[role="button"],input[type="submit"],' +
    'input[type="button"],input[type="reset"],a.btn,a.btnGhost';

  /* Chrome that is not really an action - a scrim, a toast dismiss - is left
     alone; anything can opt out with data-noshake. */
  var DENY = '.sideScrim,.groupHead,.toast button,[data-noshake]';

  var PHI = 1.618033988749895;
  var CYCLE = 3;
  var seq = 0;
  var observer = null;
  var watching = new WeakSet();

  function eligible(el) {
    if (!el || typeof el.matches !== 'function') return false;
    if (!el.matches(ELIGIBLE)) return false;
    if (el.matches(DENY)) return false;
    if (el.hasAttribute('disabled')) return false;
    if (el.classList.contains('loading')) return false;
    if (el.getAttribute('aria-busy') === 'true') return false;
    return true;
  }

  function begin(el) {
    if (el.classList.contains('shakeBtn')) return;
    var offset = (seq++ * PHI) % CYCLE;
    el.style.setProperty('--btn-shake-delay', (-offset).toFixed(3) + 's');
    el.classList.add('shakeBtn');
  }

  function end(el) {
    el.classList.remove('shakeBtn');
  }

  function observe(el) {
    if (watching.has(el)) return;
    watching.add(el);
    if (observer) observer.observe(el);
    else begin(el);
  }

  function release(el) {
    if (observer && watching.has(el)) observer.unobserve(el);
    watching.delete(el);
    end(el);
  }

  function scan(root) {
    if (root.nodeType === 1 && eligible(root)) observe(root);
    if (typeof root.querySelectorAll === 'function') {
      var found = root.querySelectorAll(ELIGIBLE);
      for (var i = 0; i < found.length; i++) {
        if (eligible(found[i])) observe(found[i]);
      }
    }
  }

  function refresh(target) {
    if (eligible(target)) observe(target);
    else if (watching.has(target)) release(target);
  }

  function start() {
    var reduce = false;
    try {
      reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    } catch (e) {
      /* a browser without matchMedia keeps the gentle default */
    }
    if (reduce) return;

    if (typeof IntersectionObserver !== 'undefined') {
      observer = new IntersectionObserver(function (entries) {
        for (var i = 0; i < entries.length; i++) {
          if (entries[i].isIntersecting) begin(entries[i].target);
          else end(entries[i].target);
        }
      }, { rootMargin: '140px 0px', threshold: 0 });
    }

    var boot = function () {
      if (!document.body) return;
      scan(document.body);
      var mo = new MutationObserver(function (mutations) {
        for (var i = 0; i < mutations.length; i++) {
          var m = mutations[i];
          if (m.type === 'childList') {
            for (var j = 0; j < m.addedNodes.length; j++) {
              if (m.addedNodes[j].nodeType === 1) scan(m.addedNodes[j]);
            }
          } else if (m.target.nodeType === 1) {
            refresh(m.target);
          }
        }
      });
      mo.observe(document.body, {
        childList: true,
        subtree: true,
        attributes: true,
        attributeFilter: ['class', 'disabled', 'aria-busy'],
      });
    };

    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', boot, { once: true });
    } else {
      boot();
    }
  }

  start();
})();
