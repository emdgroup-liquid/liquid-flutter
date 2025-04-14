'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"index.html": "3865c2c06aadd75338f911aacce9e85f",
"/": "3865c2c06aadd75338f911aacce9e85f",
"assets/NOTICES": "1086dc6d8ec5b80a491fa523eb432d61",
"assets/assets/dark_vs.json": "ddbf06cbea8463d0758e879190db5d04",
"assets/assets/dark_plus.json": "da330ec31dc628f36fb915c6b4edae31",
"assets/liquid_flutter_icon.jpg": "18b5577dc22abfe476b3e0c0470abfd6",
"assets/lib/components/submit.dart": "ab4e21a6ce4dabcc27e1a297d3c4aaf9",
"assets/lib/components/hint.dart": "6c5d3def6fc58d6a1ce21fbcaf0f9be3",
"assets/lib/components/divider.dart": "0034aadd97ee714d1e48549059e004ae",
"assets/lib/components/component_well.dart": "de27e5584d18057b619ec20ed6a865e8",
"assets/lib/components/notification.dart": "53d25ffd66fa72fe4fabd95d730b71e6",
"assets/lib/components/list.dart": "5ff9be0699bba98cb71c78646a2d6536",
"assets/lib/components/card.dart": "8d98b544c2f67c88088ae14da3990823",
"assets/lib/components/orb.dart": "ae6c9bcf4872a8dba9974e6ecac1acd3",
"assets/lib/components/indicator.dart": "1165f8cce465ed622b477bec1aac7d5e",
"assets/lib/components/master_detail.dart": "23e0baa4e69712bf6d634d0ce5dee305",
"assets/lib/components/loader.dart": "252915147e5df8f4e0ccd0401a44bea7",
"assets/lib/components/breadcrumb.dart": "656f05c1444985ac72562d264512c4c4",
"assets/lib/components/badge.dart": "9804b9f8c3543506919495fb85ba65b5",
"assets/lib/components/reactive_form.dart": "fca0c483a07b136e49b4c4b1dc5c1453",
"assets/lib/components/checkbox.dart": "ead13f0d00c5ccbcada15f5fed6b71c5",
"assets/lib/components/input.dart": "15f3bb706a222a83cc594fe98cb07fc2",
"assets/lib/components/select.dart": "a19d67e85678431bc96dc60b30877b49",
"assets/lib/components/form.dart": "85b005d8c0da0388a50251dbe3a05d4e",
"assets/lib/components/autospace.dart": "995a9c57a57b1a4d6f3b2bf7862ed7fc",
"assets/lib/components/radio.dart": "010e0cc89eccec1b194372cfaf19eb14",
"assets/lib/components/slider.dart": "72810c6c93ee431af24df3b65df28da7",
"assets/lib/components/demo_code_dialog.dart": "1a0de6a5cf945aa25150c26365e4851d",
"assets/lib/components/list_full_screen.dart": "45b4436f5f6544f187eb708cfe13fcb7",
"assets/lib/components/toggle.dart": "03a874c85d949ee0c6a6eee0a78b8fa1",
"assets/lib/components/exception.dart": "c72062eecb05661ab0c2af89145d5323",
"assets/lib/components/modal.dart": "06c5a643e64b165a0b4892b9e7ada8cb",
"assets/lib/components/choose.dart": "ee02f107cf4c0717d692073b4cdd70d5",
"assets/lib/components/components_accordion.dart": "8f2f6c4f98ba1da6ec2374d8bc744615",
"assets/lib/components/table.dart": "0233b23497d3fb87dcbb2aec4d50baf7",
"assets/lib/components/reveal.dart": "9ba4e9e4defcf0b844c1ab34a1954069",
"assets/lib/components/component_api.dart": "30146c53f2738eaf9dbef0a6a8f2e4a7",
"assets/lib/components/button.dart": "a71b1a36f20b0391ee41f16f5a05e570",
"assets/lib/components/spring.dart": "f62b7b01ca980b090b10a1ec85dcaded",
"assets/lib/components/switch.dart": "53cf840525babc508c87391d3a313042",
"assets/lib/components/runner.dart": "d843d9faaf89717ffc1d7b79f4231174",
"assets/lib/components/date_time_pickers.dart": "2d5d1bd10669b56a89d98380d71f13dc",
"assets/lib/components/context_menu.dart": "7e858b0e6090f47a2bc00ac22268da3b",
"assets/lib/components/component_page.dart": "0c3bce4f946c64bd2f2676fda0ed247f",
"assets/lib/components/icons.dart": "d20ecb377cbc0cacf059c04268c7b748",
"assets/lib/components/tab.dart": "46404067daf8d8f24285a5efcd37c18b",
"assets/lib/components/accordion.dart": "bdc9b1bda3a0819617880779634a686d",
"assets/lib/components/drawer.dart": "78674dde0913e192981b697bfc846da2",
"assets/lib/components/tag.dart": "fe784c4395f385e19ac2dc6cffb76529",
"assets/lib/components/material.dart": "4830cd1407cb261a53b4b06325f18f49",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "22f8208433f37e4708fdf58e71bdc110",
"assets/fonts/NotoSansMono-Regular.ttf": "ae466685cf0b9043ab742ca2631c5662",
"assets/fonts/NotoSansMono-Bold.ttf": "6336dc33c6e3603fab940c80c60c3e85",
"assets/fonts/MaterialIcons-Regular.otf": "5cad59c06b605287633771cf5a779ddf",
"assets/FontManifest.json": "31ccc907db71341d2b5d659b6c3e383b",
"assets/AssetManifest.bin.json": "06dddedd6311092a9af0d0f8cfb1b279",
"assets/packages/syntax_highlight/themes/dark_vs.json": "2839d5be4f19e6b315582a36a6dcd1c3",
"assets/packages/syntax_highlight/themes/dark_plus.json": "b212b7b630779cb4955e27a1c228bf71",
"assets/packages/syntax_highlight/themes/light_plus.json": "2a29ad892e1f54e93062fee13b3688c6",
"assets/packages/syntax_highlight/themes/light_vs.json": "8025deae1ca1a4d1cb803c7b9f8528a1",
"assets/packages/syntax_highlight/grammars/serverpod_protocol.json": "cc9b878a8ae5032ca4073881e5889fd5",
"assets/packages/syntax_highlight/grammars/yaml.json": "7c2dfa28161c688d8e09478a461f17bf",
"assets/packages/syntax_highlight/grammars/json.json": "e608a2cc8f3ec86a5b4af4d7025ae43f",
"assets/packages/syntax_highlight/grammars/sql.json": "957a963dfa0e8d634766e08c80e00723",
"assets/packages/syntax_highlight/grammars/dart.json": "b533a238112e4038ed399e53ca050e33",
"assets/packages/liquid_flutter/assets/warning.svg": "08ea241c8eaed01ab328fcd3a8f905d8",
"assets/packages/liquid_flutter/assets/checkmark.svg": "0178f030287d9bea497f74654a97ff04",
"assets/packages/liquid_flutter/assets/pending.svg": "852eb84a254fe38cd54a8613d2d5d0e6",
"assets/packages/liquid_flutter/assets/canceled.svg": "f79341c87e9452f117d05883abebfd85",
"assets/packages/liquid_flutter/assets/info.svg": "b3aa1ae6d87970ba1bfdd1494390bc42",
"assets/packages/liquid_flutter/assets/ongoing.svg": "fbfddad42153851148ddef7b6e5790c4",
"assets/packages/liquid_flutter/assets/cross.svg": "d08fdff9feba5f8b6df91cf1bd263f49",
"assets/packages/liquid_flutter/lib/fonts/Lato-Regular.ttf": "2d36b1a925432bae7f3c53a340868c6e",
"assets/packages/liquid_flutter/fonts/Lato-Regular.ttf": "2d36b1a925432bae7f3c53a340868c6e",
"assets/packages/liquid_flutter/fonts/Lato-Bold.ttf": "85d339d916479f729938d2911b85bf1f",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/liquid_flutter_emd_theme/lib/fonts/LiquidIcons.ttf": "d25d1f16f02fd7161174c20fc29bc189",
"assets/packages/liquid_flutter_emd_theme/lib/fonts/EMD.ttf": "f0a78c06cd939de7128d8779759bb5d8",
"assets/packages/liquid_flutter_emd_theme/fonts/LiquidIcons.ttf": "5dee2c00c1d80cd25b89a64527f3705a",
"assets/packages/liquid_flutter_emd_theme/fonts/EMD.ttf": "f0a78c06cd939de7128d8779759bb5d8",
"assets/AssetManifest.json": "61e13cbe9bdfd5ae9edee86b988edc62",
"version.json": "697c5ecc12a70ae3d1c04feff9dbcff4",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"main.dart.js": "1686e9977f35a8a253f14146cafa4bcc",
"icons/Icon-maskable-512.png": "f4939438864a41abdabeb69372336580",
"icons/Icon-192.png": "d84c33d4cf5743139f90eecd83a67ff5",
"icons/Icon-512.png": "f4939438864a41abdabeb69372336580",
"icons/Icon-maskable-192.png": "d84c33d4cf5743139f90eecd83a67ff5",
"manifest.json": "69bec415d09e0448504c9945a866a624",
"favicon.png": "8235cff2c5e6585a32f7be26c11b47e0",
"flutter_bootstrap.js": "81c0204db7ed561e392a846ae185e0a6"};
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
