/**
 * A shared, staggered shake for every button on the site.
 *
 * One tiny controller instead of a timer per button. Each eligible control is
 * handed a negative animation-delay spread evenly across the three second
 * cycle, so a screen of buttons ripples rather than pulsing in unison. The
 * animation itself lives in the stylesheet and only ever moves `translate` and
 * `rotate`, compositor properties kept separate from the `transform` a hover or
 * press already uses, so nothing about a button's size, position, colour or
 * click behaviour changes.
 *
 * Buttons added later - a menu drawn from the API, a modal, a dashboard table -
 * are picked up by a single MutationObserver. Only controls near the viewport
 * animate, so a page holding hundreds of buttons stays cheap, and anyone who
 * asked for reduced motion is left entirely alone.
 */

const ELIGIBLE = [
  'button',
  '[role="button"]',
  'input[type="submit"]',
  'input[type="button"]',
  'input[type="reset"]',
  'a.btn',
  'a.btnGhost',
  'a.navCta',
  'a.mobileCta',
  'a.drawerCall',
  '.addBtn',
  '.printBtn',
  '.jumpOrder',
  '.dropBtn',
  '.vgBtn',
  '.nav nav a',
  '.drawerNav a',
].join(',');

/* Controls that merely look like a button - a card, a row, a carousel dot or an
   invisible full-card overlay - are left alone, and anything can opt out with
   data-noshake. */
const DENY =
  '.newsCard,.newsFeature,.newsEotm,.newsMini,.payMethodRow,' +
  '.orderPanelHead,.orderPanelToggle,.dot,.linkBtn,.bedOpen,[data-noshake]';

const PHI = 1.618033988749895;
const CYCLE = 3;

let seq = 0;
let observer: IntersectionObserver | null = null;
const watching = new WeakSet<Element>();

/** A control worth shaking: a real button that is not disabled or busy. */
function eligible(el: Element): el is HTMLElement {
  const h = el as HTMLElement;
  if (typeof h.matches !== 'function') return false;
  if (!h.matches(ELIGIBLE)) return false;
  if (h.matches(DENY)) return false;
  if (h.hasAttribute('disabled')) return false;
  if (h.classList.contains('loading')) return false;
  if (h.getAttribute('aria-busy') === 'true') return false;
  return true;
}

/** Give the control its own point in the three second cycle and start it. */
function begin(el: HTMLElement): void {
  if (el.classList.contains('shakeBtn')) return;
  const offset = (seq++ * PHI) % CYCLE;
  el.style.setProperty('--btn-shake-delay', (-offset).toFixed(3) + 's');
  el.classList.add('shakeBtn');
}

function end(el: Element): void {
  el.classList.remove('shakeBtn');
}

function observe(el: Element): void {
  if (watching.has(el)) return;
  watching.add(el);
  if (observer) observer.observe(el);
  else begin(el as HTMLElement);
}

function release(el: Element): void {
  if (observer && watching.has(el)) observer.unobserve(el);
  watching.delete(el);
  end(el);
}

function scan(root: ParentNode): void {
  const self = root as Element;
  if (self.nodeType === 1 && eligible(self)) observe(self);
  if (typeof root.querySelectorAll === 'function') {
    root.querySelectorAll(ELIGIBLE).forEach((node) => {
      if (eligible(node)) observe(node);
    });
  }
}

/** Re-check a control whose class, disabled or busy state just changed. */
function refresh(target: Element): void {
  if (eligible(target)) observe(target);
  else if (watching.has(target)) release(target);
}

function start(): void {
  if (typeof window === 'undefined' || typeof document === 'undefined') return;

  let reduce = false;
  try {
    reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  } catch {
    /* a browser without matchMedia simply keeps the gentle default */
  }
  if (reduce) return;

  if (typeof IntersectionObserver !== 'undefined') {
    observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) begin(entry.target as HTMLElement);
          else end(entry.target);
        }
      },
      { rootMargin: '140px 0px', threshold: 0 },
    );
  }

  const boot = (): void => {
    if (!document.body) return;
    scan(document.body);
    const mo = new MutationObserver((mutations) => {
      for (const m of mutations) {
        if (m.type === 'childList') {
          m.addedNodes.forEach((n) => {
            if (n.nodeType === 1) scan(n as Element);
          });
        } else if (m.target.nodeType === 1) {
          refresh(m.target as Element);
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
