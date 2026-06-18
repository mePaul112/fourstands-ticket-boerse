/* FourStands Service Worker – Offline-Schale, network-first fuer eigene Dateien */
const CACHE = 'fourstands-v4';
const ASSETS = ['./', './index.html', './manifest.webmanifest', './skull.png', './icon-192.png', './icon-512.png', './header.jpg'];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(ASSETS)).then(() => self.skipWaiting()));
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  // Fremde Origins (Supabase, OpenLigaDB, Fonts/CDN) NICHT abfangen -> immer live
  if (url.origin !== location.origin) return;
  // network-first: online stets aktuelle Version, offline aus Cache
  e.respondWith(
    fetch(req)
      .then(res => { const copy = res.clone(); caches.open(CACHE).then(c => c.put(req, copy)); return res; })
      .catch(() => caches.match(req).then(r => r || caches.match('./index.html')))
  );
});
