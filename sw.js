/* Hotel Paradise on the Nile - service worker.
 *
 * What it is allowed to keep, and what it must never keep:
 *
 *   - It caches the public site's own static files: the page shells, the
 *     stylesheet, the scripts, the fonts and the hotel photographs. Those
 *     are the same for every visitor and carry no private data.
 *   - It never touches the management console, the PHP API, the downloads
 *     page or anything with a query string used to talk to the server
 *     (`?act=...`). Those requests go straight to the network, are never
 *     read from the cache and are never written to it, so one signed-in
 *     person's data can never be served to another.
 *   - An offline screen is a fallback, never a success. Nothing here lets
 *     a booking, an order or a payment look as though it was submitted
 *     when the server has not confirmed it: those pages are network-only.
 */
const VERSION = 'hpn-2026-12';
const STATIC_CACHE = VERSION + '-static';
const RUNTIME_CACHE = VERSION + '-runtime';
const OFFLINE_URL = './offline.html';

const PRECACHE = [
  './offline.html',
  './manifest.webmanifest',
  './icon-192.png',
  './icon-512.png',
  './icon-maskable-512.png',
  './logo-64.png',
  './logo-192.png',
  './logo-256.png'
];

self.addEventListener('install', event => {
  event.waitUntil((async () => {
    const cache = await caches.open(STATIC_CACHE);
    // A single missing file must not abort the whole install.
    await Promise.all(PRECACHE.map(url => cache.add(url).catch(() => {})));
    self.skipWaiting();
  })());
});

self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(
      keys.filter(k => k !== STATIC_CACHE && k !== RUNTIME_CACHE)
          .map(k => caches.delete(k))
    );
    await self.clients.claim();
  })());
});

function isConsolePath(pathname) {
  return pathname.indexOf('/backend-php/') !== -1
      || pathname.indexOf('/system/') !== -1
      || /\/api\.php$/.test(pathname)
      || /\/download\.php$/.test(pathname);
}

function isStaticAsset(pathname) {
  return pathname.indexOf('/assets/') !== -1
      || pathname.indexOf('/images/') !== -1
      || /\.(?:css|js|mjs|png|jpg|jpeg|webp|avif|gif|svg|ico|woff2?|ttf|otf)$/i.test(pathname);
}

self.addEventListener('fetch', event => {
  const request = event.request;
  if (request.method !== 'GET') return;

  let url;
  try { url = new URL(request.url); } catch (e) { return; }
  if (url.origin !== self.location.origin) return;      // cross-origin: leave it alone
  if (isConsolePath(url.pathname)) return;              // console and API: network only, never cached

  const acceptsHtml = (request.headers.get('accept') || '').indexOf('text/html') !== -1;
  const isNavigate = request.mode === 'navigate' || acceptsHtml;

  if (isNavigate) {
    event.respondWith((async () => {
      try {
        const fresh = await fetch(request);
        if (fresh && fresh.ok) {
          const cache = await caches.open(RUNTIME_CACHE);
          cache.put(request, fresh.clone()).catch(() => {});
        }
        return fresh;
      } catch (err) {
        const cached = await caches.match(request, {ignoreSearch: true});
        if (cached) return cached;
        const offline = await caches.match(OFFLINE_URL);
        if (offline) return offline;
        return new Response('You are offline.', {status: 503, headers: {'Content-Type': 'text/plain; charset=utf-8'}});
      }
    })());
    return;
  }

  if (isStaticAsset(url.pathname)) {
    event.respondWith((async () => {
      const cached = await caches.match(request);
      if (cached) {
        // Refresh quietly so a later load has the newest file.
        fetch(request).then(res => {
          if (res && res.ok) caches.open(RUNTIME_CACHE).then(c => c.put(request, res.clone()).catch(() => {}));
        }).catch(() => {});
        return cached;
      }
      try {
        const res = await fetch(request);
        if (res && res.ok) {
          const cache = await caches.open(RUNTIME_CACHE);
          cache.put(request, res.clone()).catch(() => {});
        }
        return res;
      } catch (err) {
        return new Response('', {status: 504, statusText: 'offline'});
      }
    })());
    return;
  }

  // Anything else same-origin: try the network, fall back to a cached copy.
  event.respondWith((async () => {
    try {
      return await fetch(request);
    } catch (err) {
      const cached = await caches.match(request);
      return cached || new Response('', {status: 504, statusText: 'offline'});
    }
  })());
});
