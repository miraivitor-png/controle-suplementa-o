// Service Worker — Lançamento Diário v1
const CACHE_NAME = 'lancamento-v1';
const CACHE_URLS = ['./peao.html', './manifest.json', './icons/icon-192.png'];

// Instalação: faz cache dos arquivos principais
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(CACHE_URLS))
  );
  self.skipWaiting();
});

// Ativação: remove caches antigos
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))
    )
  );
  return self.clients.claim();
});

// Fetch: tenta rede primeiro, cai no cache se offline
self.addEventListener('fetch', event => {
  // Requisições ao Supabase sempre vão direto para a rede
  if (event.request.url.includes('supabase.co')) {
    event.respondWith(fetch(event.request));
    return;
  }

  event.respondWith(
    fetch(event.request)
      .then(response => {
        if (response && response.status === 200) {
          const copy = response.clone();
          caches.open(CACHE_NAME).then(cache => cache.put(event.request, copy));
        }
        return response;
      })
      .catch(() => caches.match(event.request))
  );
});
