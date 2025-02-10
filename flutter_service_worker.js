'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"icons/Icon-maskable-192.png": "d84c33d4cf5743139f90eecd83a67ff5",
"icons/Icon-512.png": "f4939438864a41abdabeb69372336580",
"icons/Icon-192.png": "d84c33d4cf5743139f90eecd83a67ff5",
"icons/Icon-maskable-512.png": "f4939438864a41abdabeb69372336580",
"version.json": "697c5ecc12a70ae3d1c04feff9dbcff4",
"flutter_bootstrap.js": "847b265f1086c08fbb82b8befc6b939b",
"manifest.json": "69bec415d09e0448504c9945a866a624",
"main.dart.js": "18bcfc7f917ede11a2a5b00ce2c4a13a",
"index.html": "7876d7fd4e67fda78306af5af686574b",
"/": "7876d7fd4e67fda78306af5af686574b",
"assets/AssetManifest.json": "fa142b3ac559f0f8aad354cec0dedf8f",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/fonts/NotoSansMono-Regular.ttf": "ae466685cf0b9043ab742ca2631c5662",
"assets/fonts/MaterialIcons-Regular.otf": "695c8ea1f8c99c1f663d3657f75f7658",
"assets/fonts/NotoSansMono-Bold.ttf": "6336dc33c6e3603fab940c80c60c3e85",
"assets/AssetManifest.bin": "4ad4bf4d8bcc3af158bfe869cdf0172a",
"assets/packages/liquid_flutter/lib/fonts/Lato-Regular.ttf": "2d36b1a925432bae7f3c53a340868c6e",
"assets/packages/liquid_flutter/fonts/Lato-Regular.ttf": "2d36b1a925432bae7f3c53a340868c6e",
"assets/packages/liquid_flutter/fonts/Lato-Bold.ttf": "85d339d916479f729938d2911b85bf1f",
"assets/packages/liquid_flutter/assets/info.svg": "b3aa1ae6d87970ba1bfdd1494390bc42",
"assets/packages/liquid_flutter/assets/canceled.svg": "f79341c87e9452f117d05883abebfd85",
"assets/packages/liquid_flutter/assets/warning.svg": "08ea241c8eaed01ab328fcd3a8f905d8",
"assets/packages/liquid_flutter/assets/pending.svg": "852eb84a254fe38cd54a8613d2d5d0e6",
"assets/packages/liquid_flutter/assets/cross.svg": "d08fdff9feba5f8b6df91cf1bd263f49",
"assets/packages/liquid_flutter/assets/checkmark.svg": "0178f030287d9bea497f74654a97ff04",
"assets/packages/liquid_flutter/assets/ongoing.svg": "fbfddad42153851148ddef7b6e5790c4",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/packages/syntax_highlight/themes/dark_vs.json": "2839d5be4f19e6b315582a36a6dcd1c3",
"assets/packages/syntax_highlight/themes/light_plus.json": "2a29ad892e1f54e93062fee13b3688c6",
"assets/packages/syntax_highlight/themes/dark_plus.json": "b212b7b630779cb4955e27a1c228bf71",
"assets/packages/syntax_highlight/themes/light_vs.json": "8025deae1ca1a4d1cb803c7b9f8528a1",
"assets/packages/syntax_highlight/grammars/dart.json": "f8a855de8bd770569dd31041df4a8613",
"assets/packages/syntax_highlight/grammars/sql.json": "957a963dfa0e8d634766e08c80e00723",
"assets/packages/syntax_highlight/grammars/yaml.json": "7c2dfa28161c688d8e09478a461f17bf",
"assets/packages/liquid_flutter_emd_theme/lib/fonts/LiquidIcons.ttf": "d25d1f16f02fd7161174c20fc29bc189",
"assets/packages/liquid_flutter_emd_theme/lib/fonts/EMD.ttf": "f0a78c06cd939de7128d8779759bb5d8",
"assets/packages/liquid_flutter_emd_theme/fonts/LiquidIcons.ttf": "5dee2c00c1d80cd25b89a64527f3705a",
"assets/packages/liquid_flutter_emd_theme/fonts/EMD.ttf": "f0a78c06cd939de7128d8779759bb5d8",
"assets/FontManifest.json": "31ccc907db71341d2b5d659b6c3e383b",
"assets/AssetManifest.bin.json": "794cd00a3b90f65ed49459772be31781",
"assets/NOTICES": "f863c98c2ab3ae1462f062da21ce1f59",
"assets/liquid_flutter_icon.jpg": "18b5577dc22abfe476b3e0c0470abfd6",
"assets/assets/dark_vs.json": "ddbf06cbea8463d0758e879190db5d04",
"assets/assets/dark_plus.json": "da330ec31dc628f36fb915c6b4edae31",
"canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
"canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
"canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
"canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
"canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
"canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
"canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
"canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
"favicon.png": "8235cff2c5e6585a32f7be26c11b47e0"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
