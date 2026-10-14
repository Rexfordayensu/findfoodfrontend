// FindFood service worker: web push notifications and the app icon badge.
//
// It caches nothing: the app always loads fresh from the network. The server
// sends each push with the person's unread count (see backend app/notify.py),
// which is shown on the installed app's icon.
'use strict';

self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => event.waitUntil(self.clients.claim()));

function setBadge(count) {
  try {
    if (!('setAppBadge' in self.navigator)) return Promise.resolve();
    return count > 0 ? self.navigator.setAppBadge(count) : self.navigator.clearAppBadge();
  } catch (e) {
    return Promise.resolve();
  }
}

function sameOriginWindows() {
  return self.clients.matchAll({ type: 'window', includeUncontrolled: true });
}

self.addEventListener('push', (event) => {
  let data = {};
  try {
    data = event.data ? event.data.json() : {};
  } catch (e) {
    data = { title: 'FindFood', body: event.data ? event.data.text() : '' };
  }
  const url = data.url || '/';
  event.waitUntil((async () => {
    const windows = await sameOriginWindows();
    // Open copies of the app refresh their bell straight away.
    windows.forEach((w) => w.postMessage({ type: 'findfood-push', data }));
    await setBadge(Number(data.badge) || 0);
    // Someone already reading this chat gets it quietly.
    const target = new URL(url, self.location.origin).pathname;
    const watching = data.kind === 'chat' && windows.some((w) =>
      w.focused && w.visibilityState === 'visible' && new URL(w.url).pathname === target);
    await self.registration.showNotification(data.title || 'FindFood', {
      body: data.body || '',
      icon: '/icons/Icon-192.png',
      badge: '/icons/badge-96.png',
      tag: data.tag || undefined,
      renotify: Boolean(data.tag) && !watching,
      silent: watching,
      timestamp: Date.now(),
      data: { url },
    });
  })());
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  let target = new URL((event.notification.data && event.notification.data.url) || '/',
    self.location.origin);
  // Only ever open this site, whatever the payload says.
  if (target.origin !== self.location.origin) target = new URL('/', self.location.origin);
  const route = target.pathname + target.search;
  event.waitUntil((async () => {
    const windows = await sameOriginWindows();
    const open = windows.find((w) => new URL(w.url).origin === self.location.origin);
    if (open) {
      await open.focus();
      open.postMessage({ type: 'findfood-open', url: route });
      return;
    }
    await self.clients.openWindow(target.href);
  })());
});

// The browser replaced the subscription (e.g. it expired): tell the app,
// which registers the new one with the server next time it opens.
self.addEventListener('pushsubscriptionchange', (event) => {
  event.waitUntil(sameOriginWindows().then((windows) =>
    windows.forEach((w) => w.postMessage({ type: 'findfood-resubscribe' }))));
});
