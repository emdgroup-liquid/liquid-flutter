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
"index.html": "7876d7fd4e67fda78306af5af686574b",
"/": "7876d7fd4e67fda78306af5af686574b",
"assets/NOTICES": "ac510d8caa84af1de0360a8f1b8695d2",
"assets/assets/dark_vs.json": "ddbf06cbea8463d0758e879190db5d04",
"assets/assets/dark_plus.json": "da330ec31dc628f36fb915c6b4edae31",
"assets/liquid_flutter_icon.jpg": "18b5577dc22abfe476b3e0c0470abfd6",
"assets/lib/components/submit.dart": "ad3ad9ee74a23b3fae58e74c0a469ba7",
"assets/lib/components/hint.dart": "3aad0656095ca0b3ce9cb2fe1c880fce",
"assets/lib/components/divider.dart": "7ba20e79a96dd2aa420e72d6e5f088f8",
"assets/lib/components/component_well.dart": "83f78cc9b26a0a27709d30cbb0de27f2",
"assets/lib/components/notification.dart": "d183f5c777eeab154e3663b5ad966951",
"assets/lib/components/list.dart": "2949a9bfe6aa69a863d8701515f566b2",
"assets/lib/components/card.dart": "a9a41a0cd7e11813922e196585bc76cf",
"assets/lib/components/orb.dart": "0071d3a463f65088067d5ef5bcdefe72",
"assets/lib/components/indicator.dart": "9a75c10cdc8f56feb1f695053dc560d6",
"assets/lib/components/master_detail.dart": "ed56cb870a0317c558ccd8eccb9429a0",
"assets/lib/components/loader.dart": "0efa2809e0801c5ed682f41a513a823f",
"assets/lib/components/breadcrumb.dart": "48e2397650d9526b82bf535f6a47afca",
"assets/lib/components/badge.dart": "5dd15e7d7e73ecf23c0f5122c4364c07",
"assets/lib/components/checkbox.dart": "de08dcb2dc220ca940d58579f4d48bb5",
"assets/lib/components/input.dart": "56a8ebd25fc4c57935f4499cbf8b532f",
"assets/lib/components/select.dart": "9ce790cbe7199c07c5e3ba9e89a0563d",
"assets/lib/components/form.dart": "ad363555337560bdd6c4bafd95cc1434",
"assets/lib/components/autospace.dart": "d4109e6fe871a1e7b50ace4e6526eb67",
"assets/lib/components/radio.dart": "f6633ba110bd2cee2e2cd33b7918abe1",
"assets/lib/components/slider.dart": "8571f327533e7f6e1166d9aec6a4501a",
"assets/lib/components/demo_code_dialog.dart": "3caa59808e59392e5c17181f8b87e9aa",
"assets/lib/components/list_full_screen.dart": "4cde8b7d80385807424e321966bda5dd",
"assets/lib/components/toggle.dart": "96062b4bf431a5f3ac8556c7a0e207a0",
"assets/lib/components/exception.dart": "062fe7052e1ca6417100c6e215857f7c",
"assets/lib/components/modal.dart": "5482ad8ce8d5c69236ecaf074a657c0f",
"assets/lib/components/choose.dart": "89080821df3c108162c38bbc01686df0",
"assets/lib/components/components_accordion.dart": "a5fc3327fa2699a5bca4d8ae21d81cf0",
"assets/lib/components/table.dart": "91ad7390c9ecf1e1d7e1d679ea0e3163",
"assets/lib/components/reveal.dart": "c5574bffef6aebf965b116c10074ea6d",
"assets/lib/components/component_api.dart": "e321d3026c1b77459d5116d0c631058b",
"assets/lib/components/button.dart": "875f8b75836776fe85f31a8b5a7ef46f",
"assets/lib/components/spring.dart": "f62b7b01ca980b090b10a1ec85dcaded",
"assets/lib/components/switch.dart": "9b41d27680f72030a85314eeb10f65b9",
"assets/lib/components/runner.dart": "d843d9faaf89717ffc1d7b79f4231174",
"assets/lib/components/date_time_pickers.dart": "2d5d1bd10669b56a89d98380d71f13dc",
"assets/lib/components/context_menu.dart": "7e858b0e6090f47a2bc00ac22268da3b",
"assets/lib/components/component_page.dart": "2fee621b422c373658e683af25fb2342",
"assets/lib/components/icons.dart": "630cec76cb95716ffcc8d663a45fc333",
"assets/lib/components/tab.dart": "c374a547c963eb20703ebb261fe0f77d",
"assets/lib/components/accordion.dart": "6958f660e1b7ef7d63088624f03144a6",
"assets/lib/components/drawer.dart": "cab5c9c569b261dfdae89222377339d7",
"assets/lib/components/tag.dart": "8f5308c29cbefac5e98a4370655adc4a",
"assets/lib/components/material.dart": "f6180142f549539227e5a9aa490b85f5",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "9687c1c3f86f1b51db20cddfad271359",
"assets/fonts/NotoSansMono-Regular.ttf": "ae466685cf0b9043ab742ca2631c5662",
"assets/fonts/NotoSansMono-Bold.ttf": "6336dc33c6e3603fab940c80c60c3e85",
"assets/fonts/MaterialIcons-Regular.otf": "5cad59c06b605287633771cf5a779ddf",
"assets/FontManifest.json": "31ccc907db71341d2b5d659b6c3e383b",
"assets/AssetManifest.bin.json": "079ba7b0c01cb61b4cf6dd684a3c746e",
"assets/packages/syntax_highlight/themes/dark_vs.json": "2839d5be4f19e6b315582a36a6dcd1c3",
"assets/packages/syntax_highlight/themes/dark_plus.json": "b212b7b630779cb4955e27a1c228bf71",
"assets/packages/syntax_highlight/themes/light_plus.json": "2a29ad892e1f54e93062fee13b3688c6",
"assets/packages/syntax_highlight/themes/light_vs.json": "8025deae1ca1a4d1cb803c7b9f8528a1",
"assets/packages/syntax_highlight/grammars/yaml.json": "7c2dfa28161c688d8e09478a461f17bf",
"assets/packages/syntax_highlight/grammars/sql.json": "957a963dfa0e8d634766e08c80e00723",
"assets/packages/syntax_highlight/grammars/dart.json": "f8a855de8bd770569dd31041df4a8613",
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
"assets/AssetManifest.json": "9e89126c2210ccfbb080d0824fa7b50f",
"version.json": "697c5ecc12a70ae3d1c04feff9dbcff4",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"main.dart.js": "09ea8daf95884da05f069e68f7035927",
"icons/Icon-maskable-512.png": "f4939438864a41abdabeb69372336580",
"icons/Icon-192.png": "d84c33d4cf5743139f90eecd83a67ff5",
"icons/Icon-512.png": "f4939438864a41abdabeb69372336580",
"icons/Icon-maskable-192.png": "d84c33d4cf5743139f90eecd83a67ff5",
"manifest.json": "69bec415d09e0448504c9945a866a624",
"favicon.png": "8235cff2c5e6585a32f7be26c11b47e0",
"flutter_bootstrap.js": "de2e828b8e828259258892ac9e78ca3f"};
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
