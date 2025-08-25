// Service Worker for FreshThreads
// Cache version - increment when updating
const CACHE_VERSION = 'v1';
const CACHE_NAME = `freshthreads-${CACHE_VERSION}`;

// Resources to cache immediately
const STATIC_CACHE_URLS = [
    '/',
    '/index.html',
    '/products.html',
    '/about.html',
    '/contact.html',
    '/assets/css/products.css',
    '/assets/css/common.css',
    '/assets/js/error-monitor.js',
    '/assets/cart.js',
    '/favicon.svg'
];

// Cache strategies
const CACHE_STRATEGIES = {
    // Cache first for static assets
    cacheFirst: [
        /\.(?:css|js|svg|png|jpg|jpeg|gif|webp|woff|woff2|ttf)$/i
    ],
    // Network first for API calls
    networkFirst: [
        /\/api\//,
        /printify/i
    ],
    // Stale while revalidate for HTML pages
    staleWhileRevalidate: [
        /\.html$/i,
        /\/$/
    ]
};

// Install event - cache critical resources
self.addEventListener('install', event => {
    console.log('[SW] Installing service worker...');

    event.waitUntil(
        caches.open(CACHE_NAME)
            .then(cache => {
                console.log('[SW] Caching static resources...');
                return cache.addAll(STATIC_CACHE_URLS);
            })
            .then(() => {
                console.log('[SW] Static resources cached successfully');
                return self.skipWaiting();
            })
            .catch(error => {
                console.error('[SW] Failed to cache static resources:', error);
            })
    );
});

// Activate event - clean up old caches
self.addEventListener('activate', event => {
    console.log('[SW] Activating service worker...');

    event.waitUntil(
        caches.keys()
            .then(cacheNames => {
                return Promise.all(
                    cacheNames.map(cacheName => {
                        if (cacheName !== CACHE_NAME) {
                            console.log('[SW] Deleting old cache:', cacheName);
                            return caches.delete(cacheName);
                        }
                    })
                );
            })
            .then(() => {
                console.log('[SW] Service worker activated');
                return self.clients.claim();
            })
    );
});

// Fetch event - implement caching strategies
self.addEventListener('fetch', event => {
    const { request } = event;
    const url = new URL(request.url);

    // Skip non-GET requests
    if (request.method !== 'GET') {
        return;
    }

    // Skip cross-origin requests (except for allowed domains)
    if (url.origin !== location.origin && !isAllowedOrigin(url.origin)) {
        return;
    }

    // Determine caching strategy
    const strategy = getCacheStrategy(request.url);

    event.respondWith(
        handleRequest(request, strategy)
    );
});

// Determine cache strategy for a URL
function getCacheStrategy(url) {
    for (const [strategy, patterns] of Object.entries(CACHE_STRATEGIES)) {
        if (patterns.some(pattern => pattern.test(url))) {
            return strategy;
        }
    }
    return 'networkFirst'; // Default strategy
}

// Check if origin is allowed for cross-origin caching
function isAllowedOrigin(origin) {
    const allowedOrigins = [
        'https://fonts.googleapis.com',
        'https://fonts.gstatic.com',
        'https://cdnjs.cloudflare.com'
    ];
    return allowedOrigins.includes(origin);
}

// Handle request based on strategy
async function handleRequest(request, strategy) {
    switch (strategy) {
        case 'cacheFirst':
            return cacheFirst(request);
        case 'networkFirst':
            return networkFirst(request);
        case 'staleWhileRevalidate':
            return staleWhileRevalidate(request);
        default:
            return fetch(request);
    }
}

// Cache First Strategy - check cache first, fallback to network
async function cacheFirst(request) {
    try {
        const cache = await caches.open(CACHE_NAME);
        const cachedResponse = await cache.match(request);

        if (cachedResponse) {
            console.log('[SW] Cache hit:', request.url);
            return cachedResponse;
        }

        console.log('[SW] Cache miss, fetching:', request.url);
        const networkResponse = await fetch(request);

        // Cache successful responses
        if (networkResponse.ok) {
            cache.put(request, networkResponse.clone());
        }

        return networkResponse;
    } catch (error) {
        console.error('[SW] Cache first error:', error);
        // Try to serve from cache as fallback
        const cache = await caches.open(CACHE_NAME);
        const cachedResponse = await cache.match(request);
        return cachedResponse || new Response('Offline', { status: 503 });
    }
}

// Network First Strategy - try network first, fallback to cache
async function networkFirst(request) {
    try {
        const networkResponse = await fetch(request);

        if (networkResponse.ok) {
            const cache = await caches.open(CACHE_NAME);
            cache.put(request, networkResponse.clone());
        }

        return networkResponse;
    } catch (error) {
        console.log('[SW] Network failed, trying cache:', request.url);
        const cache = await caches.open(CACHE_NAME);
        const cachedResponse = await cache.match(request);
        return cachedResponse || new Response('Offline', { status: 503 });
    }
}

// Stale While Revalidate - serve from cache, update in background
async function staleWhileRevalidate(request) {
    const cache = await caches.open(CACHE_NAME);
    const cachedResponse = await cache.match(request);

    // Start network request in background
    const networkPromise = fetch(request).then(response => {
        if (response.ok) {
            cache.put(request, response.clone());
        }
        return response;
    }).catch(error => {
        console.log('[SW] Background update failed:', error);
    });

    // Return cached response immediately if available
    if (cachedResponse) {
        console.log('[SW] Serving from cache (stale):', request.url);
        return cachedResponse;
    }

    // Wait for network if no cached version
    console.log('[SW] No cache, waiting for network:', request.url);
    return networkPromise;
}

// Background sync for offline actions
self.addEventListener('sync', event => {
    if (event.tag === 'background-sync') {
        console.log('[SW] Background sync triggered');
        event.waitUntil(doBackgroundSync());
    }
});

async function doBackgroundSync() {
    // Implement background sync logic here
    // For example, sync cart data, analytics, etc.
    console.log('[SW] Performing background sync...');
}

// Handle push notifications (if needed in future)
self.addEventListener('push', event => {
    if (event.data) {
        const data = event.data.json();
        console.log('[SW] Push notification received:', data);

        const options = {
            body: data.body,
            icon: '/favicon.svg',
            badge: '/favicon.svg',
            tag: 'freshthreads-notification'
        };

        event.waitUntil(
            self.registration.showNotification(data.title, options)
        );
    }
});
