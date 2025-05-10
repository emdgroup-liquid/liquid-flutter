'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"index.html": "7876d7fd4e67fda78306af5af686574b",
"/": "7876d7fd4e67fda78306af5af686574b",
"manifest.json": "69bec415d09e0448504c9945a866a624",
"main.dart.js": "2dc3760035fe8e00678560bc9a170d77",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"flutter_bootstrap.js": "43b5a0116a62d441bbf9c7a734647261",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"favicon.png": "8235cff2c5e6585a32f7be26c11b47e0",
"icons/Icon-512.png": "f4939438864a41abdabeb69372336580",
"icons/Icon-maskable-192.png": "d84c33d4cf5743139f90eecd83a67ff5",
"icons/Icon-192.png": "d84c33d4cf5743139f90eecd83a67ff5",
"icons/Icon-maskable-512.png": "f4939438864a41abdabeb69372336580",
"assets/liquid_flutter_icon.jpg": "18b5577dc22abfe476b3e0c0470abfd6",
"assets/packages/liquid_flutter/fonts/Lato-Bold.ttf": "85d339d916479f729938d2911b85bf1f",
"assets/packages/liquid_flutter/fonts/Lato-Regular.ttf": "2d36b1a925432bae7f3c53a340868c6e",
"assets/packages/liquid_flutter/lib/fonts/Lato-Regular.ttf": "2d36b1a925432bae7f3c53a340868c6e",
"assets/packages/liquid_flutter/assets/canceled.svg": "f79341c87e9452f117d05883abebfd85",
"assets/packages/liquid_flutter/assets/cross.svg": "d08fdff9feba5f8b6df91cf1bd263f49",
"assets/packages/liquid_flutter/assets/checkmark.svg": "0178f030287d9bea497f74654a97ff04",
"assets/packages/liquid_flutter/assets/ongoing.svg": "fbfddad42153851148ddef7b6e5790c4",
"assets/packages/liquid_flutter/assets/info.svg": "b3aa1ae6d87970ba1bfdd1494390bc42",
"assets/packages/liquid_flutter/assets/pending.svg": "852eb84a254fe38cd54a8613d2d5d0e6",
"assets/packages/liquid_flutter/assets/warning.svg": "08ea241c8eaed01ab328fcd3a8f905d8",
"assets/packages/liquid_flutter_emd_theme/fonts/LiquidIcons.ttf": "5dee2c00c1d80cd25b89a64527f3705a",
"assets/packages/liquid_flutter_emd_theme/fonts/EMD.ttf": "f0a78c06cd939de7128d8779759bb5d8",
"assets/packages/liquid_flutter_emd_theme/lib/fonts/LiquidIcons.ttf": "d25d1f16f02fd7161174c20fc29bc189",
"assets/packages/liquid_flutter_emd_theme/lib/fonts/EMD.ttf": "f0a78c06cd939de7128d8779759bb5d8",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/lucide_icons_flutter/assets/build_font/LucideVariable-w100.ttf": "706d8ef2125bc8eb5134c7481958d5f5",
"assets/packages/lucide_icons_flutter/assets/build_font/LucideVariable-w300.ttf": "956c31a1d63d8e6ee21a8eafe7ac1834",
"assets/packages/lucide_icons_flutter/assets/build_font/LucideVariable-w500.ttf": "75e98a84aeb1d00d92c95681257838a4",
"assets/packages/lucide_icons_flutter/assets/build_font/LucideVariable-w600.ttf": "77ab228e7ec30c50b2a10bc6a8f06a1b",
"assets/packages/lucide_icons_flutter/assets/build_font/LucideVariable-w400.ttf": "e62e4dcabcc1b0a31af66cf1bdd8fb23",
"assets/packages/lucide_icons_flutter/assets/build_font/LucideVariable-w200.ttf": "4035ea08f67b182417322b91c9ccf6f1",
"assets/packages/lucide_icons_flutter/assets/lucide.ttf": "eb3a6b8aa16b16ea312b70820fccf0da",
"assets/packages/syntax_highlight/grammars/dart.json": "b533a238112e4038ed399e53ca050e33",
"assets/packages/syntax_highlight/grammars/serverpod_protocol.json": "cc9b878a8ae5032ca4073881e5889fd5",
"assets/packages/syntax_highlight/grammars/sql.json": "957a963dfa0e8d634766e08c80e00723",
"assets/packages/syntax_highlight/grammars/yaml.json": "7c2dfa28161c688d8e09478a461f17bf",
"assets/packages/syntax_highlight/grammars/json.json": "e608a2cc8f3ec86a5b4af4d7025ae43f",
"assets/packages/syntax_highlight/themes/dark_plus.json": "b212b7b630779cb4955e27a1c228bf71",
"assets/packages/syntax_highlight/themes/dark_vs.json": "2839d5be4f19e6b315582a36a6dcd1c3",
"assets/packages/syntax_highlight/themes/light_vs.json": "8025deae1ca1a4d1cb803c7b9f8528a1",
"assets/packages/syntax_highlight/themes/light_plus.json": "2a29ad892e1f54e93062fee13b3688c6",
"assets/FontManifest.json": "26c8097419ad0e07aa723dd0e5da4dcb",
"assets/fonts/NotoSansMono-Bold.ttf": "6336dc33c6e3603fab940c80c60c3e85",
"assets/fonts/MaterialIcons-Regular.otf": "548307f0f6b1b7bf0669a685bc048280",
"assets/fonts/NotoSansMono-Regular.ttf": "ae466685cf0b9043ab742ca2631c5662",
"assets/lib/components/data_display/tag.dart": "65c43155686bc44d0ac3a20cc224b963",
"assets/lib/components/data_display/icon.dart": "d20ecb377cbc0cacf059c04268c7b748",
"assets/lib/components/data_display/table.dart": "0233b23497d3fb87dcbb2aec4d50baf7",
"assets/lib/components/feedback/hint.dart": "6a198ac0147517f75e8208c8870db244",
"assets/lib/components/feedback/reveal.dart": "3ee7d498c7fc93d6f3dc263aef3fe577",
"assets/lib/components/feedback/exception.dart": "ecbdba9a25cf884013910296a8faacb4",
"assets/lib/components/feedback/indicator.dart": "1165f8cce465ed622b477bec1aac7d5e",
"assets/lib/components/feedback/loader.dart": "a5333fa436f52c84efccf85f75a9f085",
"assets/lib/components/feedback/notification.dart": "317369d01740ca957ac560fd30536eb8",
"assets/lib/components/feedback/badge.dart": "abb75103b25b7065e42c2df4d861231b",
"assets/lib/components/tab.dart": "86f0364a009025ca37d0dcb9b4b0cd22",
"assets/lib/components/layout/sample_list_data.dart": "7db2516be6d19451b16b934bf975b19a",
"assets/lib/components/layout/list_item.dart": "0455e467c52582ac742a473c1dc36795",
"assets/lib/components/layout/autospace.dart": "acca73cc5679ff0096d7e4cbc1137200",
"assets/lib/components/layout/accordion.dart": "03fc2df927ec98413c62ed1ce18ed6cd",
"assets/lib/components/layout/drawer.dart": "7ecde8bf54023f4b85b1c49d7afb5db8",
"assets/lib/components/layout/list.dart": "3ccc57062f6d4c84f391cd4e9732292f",
"assets/lib/components/layout/spring.dart": "9f98bfa22633a12a9ade218fcffe979b",
"assets/lib/components/layout/master_detail.dart": "7fe59b24fe86219838bdd851c76ac85f",
"assets/lib/components/layout/divider.dart": "b5d782cb61d4903c8b1506cd4fc6abf8",
"assets/lib/components/layout/list_full_screen.dart": "92a3ffee52a71f1b9b3347a9ef8ea19a",
"assets/lib/components/layout/card.dart": "6e609ee5f929665ae120e5812438526d",
"assets/lib/components/layout/components_accordion.dart": "5e3db5fc4b52756e08c4640e5500f171",
"assets/lib/components/layout/selectable_list.dart": "b901ffd49226da1cbec8d020d02bec06",
"assets/lib/components/form_elements/checkbox.dart": "0e6ee8b116ac4b07d9f0bfb7a1fd8f3b",
"assets/lib/components/form_elements/switch.dart": "9c1f0690e44629de5c35cc34b5b77bb0",
"assets/lib/components/form_elements/date_time_pickers.dart": "2d5d1bd10669b56a89d98380d71f13dc",
"assets/lib/components/form_elements/choose.dart": "0c52d1131d6b011e6900b79e48fd2a01",
"assets/lib/components/form_elements/toggle.dart": "ed6c6e514f0aa7ac74457bbc82ba923d",
"assets/lib/components/form_elements/slider.dart": "cf5b2cf99500c216b8921e25e93a7e85",
"assets/lib/components/form_elements/submit.dart": "a953b16f723baf2b1fa79490b8119e03",
"assets/lib/components/form_elements/radio.dart": "932ca53fb6e8cc4538a5ad2d91b8b054",
"assets/lib/components/form_elements/select.dart": "6babf5948bb91b44d6ffcef0e265c624",
"assets/lib/components/form_elements/input.dart": "67eb34b3cdc53008e9b434847bfede31",
"assets/lib/components/form_elements/form.dart": "5361b45a897b583536969aea207f7911",
"assets/lib/components/form_elements/reactive_form.dart": "b4b89d9d4f232a2a47d63c45bdfae759",
"assets/lib/components/component_page.dart": "7883b3b8721d9605b06967c78a1faf2b",
"assets/lib/components/material.dart": "488cd0e26f5850909ee023a98665092b",
"assets/lib/components/demo_code_dialog.dart": "e9a9613c0e85554ed43494c600864048",
"assets/lib/components/interaction/action_runner.dart": "d843d9faaf89717ffc1d7b79f4231174",
"assets/lib/components/interaction/breadcrumb.dart": "27930ccd2392e698d2a1156dbe98659e",
"assets/lib/components/interaction/button.dart": "4039eedd816f91791612f40af0fa0cec",
"assets/lib/components/interaction/orb.dart": "965ef277d10c8ae290b4ac5568715d30",
"assets/lib/components/interaction/context_menu.dart": "07e1ff5c60d944d0224dd59b255d26ab",
"assets/lib/components/interaction/modal.dart": "f4b805e9742108f9fefdf4b70df9be74",
"assets/lib/components/component_api.dart": "d63e28aa6d5ac9077fd0a1cf1d3401c3",
"assets/AssetManifest.bin": "9a60eb585dcddbbd13254bc80021a865",
"assets/AssetManifest.bin.json": "5adc121a2a5a54e6ef8eac10dc5e07ae",
"assets/NOTICES": "9b3085f8a4db7aa8f6e86de4c47032dd",
"assets/assets/dark_plus.json": "da330ec31dc628f36fb915c6b4edae31",
"assets/assets/dark_vs.json": "ddbf06cbea8463d0758e879190db5d04",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.json": "225e524cb25d9dad8ede4293447cf4cf",
"version.json": "697c5ecc12a70ae3d1c04feff9dbcff4"};
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
