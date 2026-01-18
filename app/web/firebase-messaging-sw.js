// Firebase Messaging Service Worker
// This service worker handles push notifications when the app is in background

importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

const firebaseConfig = {
  apiKey: "AIzaSyCtWe0-bt9x7zLGav4zzIvOWJp62OppkkY",
  authDomain: "vezuway-23673.firebaseapp.com",
  projectId: "vezuway-23673",
  storageBucket: "vezuway-23673.firebasestorage.app",
  messagingSenderId: "1002793405640",
  appId: "1:1002793405640:web:62f350f0c39db9b5c229fd"
};

firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message:', payload);

  const notificationTitle = payload.notification?.title || 'Nueva notificacion';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: payload.data?.tag || 'default',
    data: payload.data || {},
    vibrate: [100, 50, 100],
    requireInteraction: false,
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification click
self.addEventListener('notificationclick', (event) => {
  console.log('[firebase-messaging-sw.js] Notification clicked:', event);
  event.notification.close();

  // Get click action URL from notification data
  const data = event.notification.data || {};
  let targetUrl = '/';

  // Navigate based on notification data
  if (data.route) {
    targetUrl = data.route;
  } else if (data.package_id) {
    targetUrl = '/packages/' + data.package_id;
  } else if (data.route_id) {
    targetUrl = '/routes/' + data.route_id;
  }

  // Focus existing window or open new one
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((windowClients) => {
      // Check if there's already a window open
      for (const client of windowClients) {
        if (client.url.includes(self.location.origin) && 'focus' in client) {
          client.focus();
          if (targetUrl !== '/') {
            client.navigate(targetUrl);
          }
          return;
        }
      }
      // No window open, open a new one
      if (clients.openWindow) {
        return clients.openWindow(targetUrl);
      }
    })
  );
});

// Service worker installation
self.addEventListener('install', (event) => {
  console.log('[firebase-messaging-sw.js] Service Worker installed');
  self.skipWaiting();
});

// Service worker activation
self.addEventListener('activate', (event) => {
  console.log('[firebase-messaging-sw.js] Service Worker activated');
  event.waitUntil(clients.claim());
});
