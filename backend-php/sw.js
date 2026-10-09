/*
 * The console's service worker. Its only job is to receive a Browser Web Push
 * message and show it as a notification, and to open the notifications page
 * when the notification is tapped. It deliberately does NOT cache anything:
 * the console is live data, and a stale booking list would be worse than a
 * slow one.
 *
 * A service worker must be served from the folder it controls. This one sits
 * in backend-php/, so it can only affect /backend-php/ - never the public site.
 */

self.addEventListener('install', function(){ self.skipWaiting(); });

self.addEventListener('activate', function(event){
  event.waitUntil(self.clients.claim());
});

self.addEventListener('push', function(event){
  var payload = {};
  try { payload = event.data ? event.data.json() : {}; }
  catch (e) { payload = { title: 'Hotel Paradise on the Nile', body: event.data ? event.data.text() : '' }; }

  var title = payload.title || 'Hotel Paradise on the Nile';
  var options = {
    body: payload.body || 'You have a new notification.',
    icon: '../images/icon-192.png',
    badge: '../images/icon-192.png',
    tag: payload.tag || 'hpn-notification',
    renotify: true,
    data: payload.data || {}
  };
  event.waitUntil(self.registration.showNotification(title, options));
});

self.addEventListener('notificationclick', function(event){
  event.notification.close();
  var target = 'index.php?page=notifications';
  if (event.notification.data && event.notification.data.url) target = event.notification.data.url;
  event.waitUntil(
    self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function(list){
      for (var i = 0; i < list.length; i++){
        if (list[i].url.indexOf('page=notifications') !== -1 && 'focus' in list[i]) return list[i].focus();
      }
      if (self.clients.openWindow) return self.clients.openWindow(target);
    })
  );
});