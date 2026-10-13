/*
 * A shared, staggered shake that only ever touches controls the console has
 * deliberately marked as its recommended actions.
 *
 * "Recommended" is a choice, never a sweep: only an element carrying the
 * .btnAttn class is ever asked to ripple, and only the notification bell
 * joins in by itself - and then only while its unread badge is showing. A
 * table, a toolbar or a form full of buttons stays perfectly still, so a
 * screen with a hundred actions never looks like it is trembling and the eye
 * is drawn to the one button that actually wants it. A module opts a control
 * in by adding class="... btnAttn"; the animation lives in admin.css and only
 * ever moves `translate` and `rotate`, which sit apart from the `transform` a
 * hover or press already uses, so no button's size, place, colour or
 * behaviour changes. It rests the instant a control is pointed at, focused,
 * pressed, disabled, submitting or loading.
 *
 * Buttons drawn later - a table refreshed over the network, a modal, a panel -
 * are caught by one MutationObserver, only controls near the viewport animate,
 * and anyone who asked for reduced motion is left entirely alone.
 */
(function () {
  'use strict';

  /* The opt-in marker and the one automatic exception: the bell, which shakes
     only while it has something to ring about. */
  var MARK = '.btnAttn';
  var BELL = 'notifyBtn';
  var BADGE = 'notifyBadge';

  var PHI = 1.618033988749895;
  var CYCLE = 3;
  var seq = 0;
  var observer = null;
  var watching = new WeakSet();

  function bellLive() {
    var b = document.getElementById(BADGE);
    return !!b && !b.hidden;
  }

  function eligible(el) {
    if (!el || typeof el.matches !== 'function') return false;
    if (el.hasAttribute('disabled')) return false;
    if (el.classList.contains('loading')) return false;
    if (el.getAttribute('aria-busy') === 'true') return false;
    if (el.classList.contains('btnAttn')) return true;
    if (el.id === BELL) return bellLive();
    return false;
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
      var marked = root.querySelectorAll(MARK);
      for (var i = 0; i < marked.length; i++) {
        if (eligible(marked[i])) observe(marked[i]);
      }
    }
    if (root === document || root === document.body) bellSync();
  }

  function refresh(target) {
    if (eligible(target)) observe(target);
    else if (watching.has(target)) release(target);
    if (target.id === BELL || target.id === BADGE) bellSync();
  }

  function bellSync() {
    var bellEl = document.getElementById(BELL);
    if (!bellEl) return;
    if (bellLive()) begin(bellEl); else end(bellEl);
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
        attributeFilter: ['class', 'disabled', 'aria-busy', 'hidden'],
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