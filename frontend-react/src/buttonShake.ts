/**
 * A premium press response for every action control on the site.
 *
 * The site used to give every button a slow, continuous shake. It read as
 * restless rather than luxurious, so the idle motion is gone. What is left is
 * one deliberate response to an actual press: a soft gold ripple that opens
 * from the point the pointer or the finger touched, and fades away. Nothing
 * moves on its own, so a screen of controls is calm until a guest uses one,
 * and anyone who asked for reduced motion is left entirely alone.
 *
 * The ripple is drawn as a single element per press, appended to the control
 * and removed the moment it has finished. It only ever animates transform and
 * opacity, so a button's size, place, colour, shadow and click behaviour are
 * untouched.
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
  '.navSignIn',
  '.drawerNav a',
  '.catChip',
  '.gatePrimary',
  '.gateSecondary',
].join(',');

/* Controls that merely look like a button - a card, a row, a carousel dot or an
   invisible full-card overlay - are left alone, and anything can opt out with
   data-noshake. */
const DENY =
  '.newsCard,.newsFeature,.newsEotm,.newsMini,.payMethodRow,' +
  '.orderPanelHead,.orderPanelToggle,.dot,.linkBtn,.bedOpen,[data-noshake]';

let reduce = false;
try {
  reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
} catch {
  /* a browser without matchMedia simply keeps the gentle default */
}

/** A control worth answering: a real button that is not disabled or busy. */
function eligible(el: Element | null): el is HTMLElement {
  if (!el) return false;
  const h = el as HTMLElement;
  if (typeof h.matches !== 'function') return false;
  if (!h.matches(ELIGIBLE)) return false;
  if (h.closest(DENY)) return false;
  if (h.hasAttribute('disabled')) return false;
  if (h.classList.contains('loading')) return false;
  if (h.getAttribute('aria-busy') === 'true') return false;
  return true;
}

/** A soft ring of light, opening from where the control was touched. */
function ripple(host: HTMLElement, x: number, y: number): void {
  if (reduce) return;
  const box = host.getBoundingClientRect();
  const size = Math.max(box.width, box.height) * 2.2;
  const span = document.createElement('span');
  span.className = 'pressRipple';
  span.setAttribute('aria-hidden', 'true');
  span.style.width = size + 'px';
  span.style.height = size + 'px';
  span.style.left = (x - box.left) + 'px';
  span.style.top = (y - box.top) + 'px';
  try {
    host.appendChild(span);
  } catch {
    /* a void control such as <input> cannot hold a child; leave it be */
    return;
  }
  host.classList.add('pressHost');
  window.setTimeout(() => span.remove(), 640);
}

function onDown(e: PointerEvent): void {
  const target = e.target instanceof Element ? e.target.closest(ELIGIBLE) : null;
  if (!eligible(target)) return;
  ripple(target, e.clientX, e.clientY);
}

if (typeof window !== 'undefined' && typeof document !== 'undefined') {
  document.addEventListener('pointerdown', onDown, {passive: true});
}
