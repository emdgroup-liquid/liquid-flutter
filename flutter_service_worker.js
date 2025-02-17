'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"icons/Icon-maskable-512.png": "f4939438864a41abdabeb69372336580",
"icons/Icon-512.png": "f4939438864a41abdabeb69372336580",
"icons/Icon-maskable-192.png": "d84c33d4cf5743139f90eecd83a67ff5",
"icons/Icon-192.png": "d84c33d4cf5743139f90eecd83a67ff5",
"flutter_bootstrap.js": "35e36b22eb55b5c4a8cfd010fd32a10f",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.js": "ba4a8ae1a65ff3ad81c6818fd47e348b",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/canvaskit.js": "6cfe36b4647fbfa15683e09e7dd366bc",
"main.dart.js": "039c4ac6785c4e7c062168b355d0f035",
"version.json": "697c5ecc12a70ae3d1c04feff9dbcff4",
"assets/packages/syntax_highlight/grammars/yaml.json": "7c2dfa28161c688d8e09478a461f17bf",
"assets/packages/syntax_highlight/grammars/dart.json": "f8a855de8bd770569dd31041df4a8613",
"assets/packages/syntax_highlight/grammars/sql.json": "957a963dfa0e8d634766e08c80e00723",
"assets/packages/syntax_highlight/themes/dark_vs.json": "2839d5be4f19e6b315582a36a6dcd1c3",
"assets/packages/syntax_highlight/themes/light_vs.json": "8025deae1ca1a4d1cb803c7b9f8528a1",
"assets/packages/syntax_highlight/themes/dark_plus.json": "b212b7b630779cb4955e27a1c228bf71",
"assets/packages/syntax_highlight/themes/light_plus.json": "2a29ad892e1f54e93062fee13b3688c6",
"assets/packages/liquid_flutter_emd_theme/lib/fonts/EMD.ttf": "f0a78c06cd939de7128d8779759bb5d8",
"assets/packages/liquid_flutter_emd_theme/lib/fonts/LiquidIcons.ttf": "d25d1f16f02fd7161174c20fc29bc189",
"assets/packages/liquid_flutter_emd_theme/fonts/EMD.ttf": "f0a78c06cd939de7128d8779759bb5d8",
"assets/packages/liquid_flutter_emd_theme/fonts/LiquidIcons.ttf": "5dee2c00c1d80cd25b89a64527f3705a",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/liquid_flutter/lib/fonts/Lato-Regular.ttf": "2d36b1a925432bae7f3c53a340868c6e",
"assets/packages/liquid_flutter/assets/ongoing.svg": "fbfddad42153851148ddef7b6e5790c4",
"assets/packages/liquid_flutter/assets/warning.svg": "08ea241c8eaed01ab328fcd3a8f905d8",
"assets/packages/liquid_flutter/assets/canceled.svg": "f79341c87e9452f117d05883abebfd85",
"assets/packages/liquid_flutter/assets/cross.svg": "d08fdff9feba5f8b6df91cf1bd263f49",
"assets/packages/liquid_flutter/assets/pending.svg": "852eb84a254fe38cd54a8613d2d5d0e6",
"assets/packages/liquid_flutter/assets/checkmark.svg": "0178f030287d9bea497f74654a97ff04",
"assets/packages/liquid_flutter/assets/info.svg": "b3aa1ae6d87970ba1bfdd1494390bc42",
"assets/packages/liquid_flutter/fonts/Lato-Bold.ttf": "85d339d916479f729938d2911b85bf1f",
"assets/packages/liquid_flutter/fonts/Lato-Regular.ttf": "2d36b1a925432bae7f3c53a340868c6e",
"assets/FontManifest.json": "31ccc907db71341d2b5d659b6c3e383b",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.json": "fa142b3ac559f0f8aad354cec0dedf8f",
"assets/assets/dark_vs.json": "ddbf06cbea8463d0758e879190db5d04",
"assets/assets/dark_plus.json": "da330ec31dc628f36fb915c6b4edae31",
"assets/NOTICES": "ac510d8caa84af1de0360a8f1b8695d2",
"assets/AssetManifest.bin": "4ad4bf4d8bcc3af158bfe869cdf0172a",
"assets/fonts/NotoSansMono-Bold.ttf": "6336dc33c6e3603fab940c80c60c3e85",
"assets/fonts/NotoSansMono-Regular.ttf": "ae466685cf0b9043ab742ca2631c5662",
"assets/fonts/MaterialIcons-Regular.otf": "ad5399f07d6aa5f434a84dc10719334a",
"assets/liquid_flutter_icon.jpg": "18b5577dc22abfe476b3e0c0470abfd6",
"assets/AssetManifest.bin.json": "794cd00a3b90f65ed49459772be31781",
"favicon.png": "8235cff2c5e6585a32f7be26c11b47e0",
"index.html": "7876d7fd4e67fda78306af5af686574b",
"/": "7876d7fd4e67fda78306af5af686574b",
"manifest.json": "69bec415d09e0448504c9945a866a624",
"flutter.js": "76f08d47ff9f5715220992f993002504"};
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
