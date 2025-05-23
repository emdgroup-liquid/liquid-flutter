'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"icons/Icon-maskable-192.png": "d84c33d4cf5743139f90eecd83a67ff5",
"icons/Icon-192.png": "d84c33d4cf5743139f90eecd83a67ff5",
"icons/Icon-maskable-512.png": "f4939438864a41abdabeb69372336580",
"icons/Icon-512.png": "f4939438864a41abdabeb69372336580",
"assets/fonts/NotoSansMono-Regular.ttf": "ae466685cf0b9043ab742ca2631c5662",
"assets/fonts/NotoSansMono-Bold.ttf": "6336dc33c6e3603fab940c80c60c3e85",
"assets/fonts/MaterialIcons-Regular.otf": "548307f0f6b1b7bf0669a685bc048280",
"assets/AssetManifest.bin.json": "5adc121a2a5a54e6ef8eac10dc5e07ae",
"assets/AssetManifest.bin": "9a60eb585dcddbbd13254bc80021a865",
"assets/AssetManifest.json": "225e524cb25d9dad8ede4293447cf4cf",
"assets/lib/components/demo_code_dialog.dart": "e9a9613c0e85554ed43494c600864048",
"assets/lib/components/interaction/context_menu.dart": "9faa056603d196d898b3fb66bb121cf2",
"assets/lib/components/interaction/modal.dart": "62413c185726622cc659638bb79eb968",
"assets/lib/components/interaction/breadcrumb.dart": "35c58eedb849046152d6daa86b82f53c",
"assets/lib/components/interaction/orb.dart": "395cba4c9d7bbfdc0448e3d3069aad3d",
"assets/lib/components/interaction/action_runner.dart": "bc2a068f3786ee4570fe73b0fae54eac",
"assets/lib/components/interaction/button.dart": "f7a579fc07afa625bf9ed3494c4e833c",
"assets/lib/components/form_elements/input.dart": "33a01d0fa97313fcc7d5a3db2502d1e9",
"assets/lib/components/form_elements/reactive_form.dart": "7eaebc8e41bb35b5ba7277f4819ea6c9",
"assets/lib/components/form_elements/checkbox.dart": "95f4c36b79393450c1f050e77fe0e845",
"assets/lib/components/form_elements/date_time_pickers.dart": "bdc3f367a7584703488e4e89a9bb5475",
"assets/lib/components/form_elements/choose.dart": "24a577e92877db5362212e28da04fef9",
"assets/lib/components/form_elements/toggle.dart": "39e82325c0dd7597e175813feb2c514c",
"assets/lib/components/form_elements/select.dart": "11bd7cdf3d32c768e76c74820ae56fd0",
"assets/lib/components/form_elements/form.dart": "a655908faf96448596772a6fbc6f4f87",
"assets/lib/components/form_elements/submit.dart": "dccae90e4063ab5525e575bd35dd411b",
"assets/lib/components/form_elements/slider.dart": "dde5e4e6602c30afb19650be560138aa",
"assets/lib/components/form_elements/switch.dart": "747b6c6618b41e3ac7bd0acf31e6b6c7",
"assets/lib/components/form_elements/radio.dart": "ef52125878d9bbb23949a526e5da7f6f",
"assets/lib/components/tab.dart": "3dc0956226c4f5ac736a62cce84d0680",
"assets/lib/components/material.dart": "7a61394ad011d21adf8dc16e716a9efa",
"assets/lib/components/feedback/notification.dart": "fa41230612ede1fb788a02f85f5fd3af",
"assets/lib/components/feedback/reveal.dart": "ef881f22e173c6e68f1d5e4e722632af",
"assets/lib/components/feedback/hint.dart": "c2638dd13f6c3d8747c9d5801930ef83",
"assets/lib/components/feedback/badge.dart": "9e92991cdb6d333c327dc41f22da18e7",
"assets/lib/components/feedback/loader.dart": "ec9edde62ff2050ec4ae2e31fe64e5df",
"assets/lib/components/feedback/exception.dart": "3a89713958f74c68119ce054bd3408d7",
"assets/lib/components/feedback/indicator.dart": "f9d97dc3fec5b01e0d2485878523d865",
"assets/lib/components/layout/list.dart": "2b74bb618e38c83bd1b594e30defa9f4",
"assets/lib/components/layout/drawer.dart": "7b549f1f53ce9277c729b9a72e6ed011",
"assets/lib/components/layout/card.dart": "265df14039d4bb7a359cc139d198b87d",
"assets/lib/components/layout/components_accordion.dart": "5e3db5fc4b52756e08c4640e5500f171",
"assets/lib/components/layout/list_item.dart": "3f25b9b6046855697071d4905c696966",
"assets/lib/components/layout/sample_list_data.dart": "7db2516be6d19451b16b934bf975b19a",
"assets/lib/components/layout/accordion.dart": "4a98dd3058f39a427a878e0bea759cb6",
"assets/lib/components/layout/divider.dart": "ae14e6ca965497042ff6ce2846ce7509",
"assets/lib/components/layout/spring.dart": "0b460470a83760f945d8d496b1fd41a8",
"assets/lib/components/layout/selectable_list.dart": "676d34329f228c8e4eefb0184dfc6e83",
"assets/lib/components/layout/master_detail.dart": "747f6dd9a73c0ff075b7c1132fed3502",
"assets/lib/components/layout/autospace.dart": "0640e7872e413e6df897500d371a1430",
"assets/lib/components/layout/list_full_screen.dart": "92a3ffee52a71f1b9b3347a9ef8ea19a",
"assets/lib/components/component_api.dart": "d63e28aa6d5ac9077fd0a1cf1d3401c3",
"assets/lib/components/data_display/tag.dart": "527becdbed847474489c9935dae3667c",
"assets/lib/components/data_display/icon.dart": "9724b0758d964a5649e1c38d451904c9",
"assets/lib/components/data_display/table.dart": "abb250fe9a75cd17386d2ac6c76fefe3",
"assets/lib/components/component_page.dart": "03343570b44c52345cf86903f0aa5180",
"assets/assets/dark_plus.json": "da330ec31dc628f36fb915c6b4edae31",
"assets/assets/dark_vs.json": "ddbf06cbea8463d0758e879190db5d04",
"assets/liquid_flutter_icon.jpg": "18b5577dc22abfe476b3e0c0470abfd6",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "825e75415ebd366b740bb49659d7a5c6",
"assets/packages/liquid_flutter/fonts/Lato-Bold.ttf": "85d339d916479f729938d2911b85bf1f",
"assets/packages/liquid_flutter/fonts/Lato-Regular.ttf": "2d36b1a925432bae7f3c53a340868c6e",
"assets/packages/liquid_flutter/lib/fonts/Lato-Regular.ttf": "2d36b1a925432bae7f3c53a340868c6e",
"assets/packages/liquid_flutter/assets/pending.svg": "852eb84a254fe38cd54a8613d2d5d0e6",
"assets/packages/liquid_flutter/assets/warning.svg": "08ea241c8eaed01ab328fcd3a8f905d8",
"assets/packages/liquid_flutter/assets/ongoing.svg": "fbfddad42153851148ddef7b6e5790c4",
"assets/packages/liquid_flutter/assets/info.svg": "b3aa1ae6d87970ba1bfdd1494390bc42",
"assets/packages/liquid_flutter/assets/canceled.svg": "f79341c87e9452f117d05883abebfd85",
"assets/packages/liquid_flutter/assets/cross.svg": "d08fdff9feba5f8b6df91cf1bd263f49",
"assets/packages/liquid_flutter/assets/checkmark.svg": "0178f030287d9bea497f74654a97ff04",
"assets/packages/syntax_highlight/grammars/yaml.json": "7c2dfa28161c688d8e09478a461f17bf",
"assets/packages/syntax_highlight/grammars/json.json": "e608a2cc8f3ec86a5b4af4d7025ae43f",
"assets/packages/syntax_highlight/grammars/sql.json": "957a963dfa0e8d634766e08c80e00723",
"assets/packages/syntax_highlight/grammars/dart.json": "b533a238112e4038ed399e53ca050e33",
"assets/packages/syntax_highlight/grammars/serverpod_protocol.json": "cc9b878a8ae5032ca4073881e5889fd5",
"assets/packages/syntax_highlight/themes/dark_plus.json": "b212b7b630779cb4955e27a1c228bf71",
"assets/packages/syntax_highlight/themes/dark_vs.json": "2839d5be4f19e6b315582a36a6dcd1c3",
"assets/packages/syntax_highlight/themes/light_vs.json": "8025deae1ca1a4d1cb803c7b9f8528a1",
"assets/packages/syntax_highlight/themes/light_plus.json": "2a29ad892e1f54e93062fee13b3688c6",
"assets/packages/lucide_icons_flutter/assets/build_font/LucideVariable-w200.ttf": "4035ea08f67b182417322b91c9ccf6f1",
"assets/packages/lucide_icons_flutter/assets/build_font/LucideVariable-w100.ttf": "706d8ef2125bc8eb5134c7481958d5f5",
"assets/packages/lucide_icons_flutter/assets/build_font/LucideVariable-w500.ttf": "75e98a84aeb1d00d92c95681257838a4",
"assets/packages/lucide_icons_flutter/assets/build_font/LucideVariable-w600.ttf": "77ab228e7ec30c50b2a10bc6a8f06a1b",
"assets/packages/lucide_icons_flutter/assets/build_font/LucideVariable-w400.ttf": "e62e4dcabcc1b0a31af66cf1bdd8fb23",
"assets/packages/lucide_icons_flutter/assets/build_font/LucideVariable-w300.ttf": "956c31a1d63d8e6ee21a8eafe7ac1834",
"assets/packages/lucide_icons_flutter/assets/lucide.ttf": "eb3a6b8aa16b16ea312b70820fccf0da",
"assets/packages/liquid_flutter_emd_theme/fonts/LiquidIcons.ttf": "5dee2c00c1d80cd25b89a64527f3705a",
"assets/packages/liquid_flutter_emd_theme/fonts/EMD.ttf": "f0a78c06cd939de7128d8779759bb5d8",
"assets/packages/liquid_flutter_emd_theme/lib/fonts/LiquidIcons.ttf": "d25d1f16f02fd7161174c20fc29bc189",
"assets/packages/liquid_flutter_emd_theme/lib/fonts/EMD.ttf": "f0a78c06cd939de7128d8779759bb5d8",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/FontManifest.json": "26c8097419ad0e07aa723dd0e5da4dcb",
"assets/NOTICES": "45865262a8b07f3e9263b18028e30ac2",
"main.dart.js": "d49b01331c1c8a035aafccbfa978a125",
"manifest.json": "69bec415d09e0448504c9945a866a624",
"version.json": "697c5ecc12a70ae3d1c04feff9dbcff4",
"canvaskit/skwasm.js.symbols": "9fe690d47b904d72c7d020bd303adf16",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/skwasm.wasm": "1c93738510f202d9ff44d36a4760126b",
"canvaskit/canvaskit.wasm": "a37f2b0af4995714de856e21e882325c",
"canvaskit/canvaskit.js.symbols": "27361387bc24144b46a745f1afe92b50",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.wasm": "c054c2c892172308ca5a0bd1d7a7754b",
"canvaskit/chromium/canvaskit.js.symbols": "f7c5e5502d577306fb6d530b1864ff86",
"flutter_bootstrap.js": "6ba06b969a42188443eea1ab80318fe3",
"favicon.png": "8235cff2c5e6585a32f7be26c11b47e0",
"index.html": "7876d7fd4e67fda78306af5af686574b",
"/": "7876d7fd4e67fda78306af5af686574b",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c"};
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
