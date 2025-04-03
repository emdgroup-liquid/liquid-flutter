# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

### [21.0.1-dev.0](https://github.com/emdgroup-liquid/liquid-flutter/compare/v21.0.0...v21.0.1-dev.0) (2025-04-03)

## [21.0.0](https://github.com/emdgroup-liquid/liquid-flutter/compare/v20.0.0...v21.0.0) (2025-03-28)


### ⚠ BREAKING CHANGES

* useRootNavigator parameter for LdChoose to superseed the navigator parameter.
* implement "lazy loading" of pages for LdPaginator and LdList

### Features

* Add LdListItemToggle component for enhanced list item interaction ([a3f1588](https://github.com/emdgroup-liquid/liquid-flutter/commit/a3f1588c898eb91dd68d1e4313c95003fe076307))
* Enhance LdAvatar with circular shape and size options ([8730cf2](https://github.com/emdgroup-liquid/liquid-flutter/commit/8730cf266f8de15559cd5e3c04ef35e2743bfc76))
* implement "lazy loading" of pages for LdPaginator and LdList ([a55741e](https://github.com/emdgroup-liquid/liquid-flutter/commit/a55741e830dc13fec9164a91d6bccce69b24ce83))
* useRootNavigator parameter for LdChoose to superseed the navigator parameter. ([8292ed8](https://github.com/emdgroup-liquid/liquid-flutter/commit/8292ed8bdba810b7b307f914b3e6d5742e068ac8))


### Bug Fixes

* Adjust alpha value for color based on theme darkness in LdTag ([263ccb7](https://github.com/emdgroup-liquid/liquid-flutter/commit/263ccb77e3a9eefdfe633e6e27b739a448999cb0))
* resolve "perform initial scroll" not working properly ([a0a119a](https://github.com/emdgroup-liquid/liquid-flutter/commit/a0a119a8b5facab28d7e217c0a62a2200e7bbd46))
* resolve linter issue ([f4e95db](https://github.com/emdgroup-liquid/liquid-flutter/commit/f4e95dbaa44f65171a3a1874b6d6cf6420ce21dc))
* Update action bar height and improve device type detection in LdModal ([c7e273e](https://github.com/emdgroup-liquid/liquid-flutter/commit/c7e273ed597e6e462de6dba7fd225012455d37d1))
* Update color expectation in tag_test ([4bf73f2](https://github.com/emdgroup-liquid/liquid-flutter/commit/4bf73f225572306081c4e1937a67e8a7d699ee99))
* Update font size values in LdThemeSize extension ([6a47dc1](https://github.com/emdgroup-liquid/liquid-flutter/commit/6a47dc13aba0e0b145219339ed6bb89166c307d9))

## [20.0.0](https://github.com/emdgroup-liquid/liquid-flutter/compare/v19.5.3...v20.0.0) (2025-03-19)


### ⚠ BREAKING CHANGES

* Add LdExceptionView as "standalone" component and make (automatic) retry functionality re-usable (#29)

### Features

* Add LdExceptionView as "standalone" component and make (automatic) retry functionality re-usable ([#29](https://github.com/emdgroup-liquid/liquid-flutter/issues/29)) ([81cbdb9](https://github.com/emdgroup-liquid/liquid-flutter/commit/81cbdb94af5c94bfddf03f021aead6ac833c09ce))

### [19.5.3](https://github.com/emdgroup-liquid/liquid-flutter/compare/v19.5.2...v19.5.3) (2025-03-18)

### [19.5.2](https://github.com/emdgroup-liquid/liquid-flutter/compare/v19.5.1...v19.5.2) (2025-03-17)

### [19.5.1](https://github.com/emdgroup-liquid/liquid-flutter/compare/v19.5.0...v19.5.1) (2025-03-10)


### Bug Fixes

* refactor doc_comparator to handle local file paths fix PR workflow to compare the correct documentation.dart files ([2aae3d1](https://github.com/emdgroup-liquid/liquid-flutter/commit/2aae3d1c05770cb4283079d59e3a6d3e341e0a3c))
* resolve issues with api change detection and corresponding workflow ([5bf72fe](https://github.com/emdgroup-liquid/liquid-flutter/commit/5bf72fe712e5c5cd47f0aa79248bda16f39f15cf))

## [19.5.0](https://github.com/emdgroup-liquid/liquid-flutter/compare/v19.4.0...v19.5.0) (2025-03-06)


### Features

* add API change type detection in pr workflow ([bef4ee8](https://github.com/emdgroup-liquid/liquid-flutter/commit/bef4ee88d31e0e6f6599baf4b3fc58a6912914f6))
* implement api documentation comparator script ([ed76990](https://github.com/emdgroup-liquid/liquid-flutter/commit/ed7699032b8d61399688ef5c7bc92df6ba98f063))


### Bug Fixes

* update pr workflow to use origin/main as reference for API detection ([0c84aa6](https://github.com/emdgroup-liquid/liquid-flutter/commit/0c84aa62d4bd3bf77e4fc2027c656406ca48ad2b))

## [19.4.0](https://github.com/emdgroup-liquid/liquid-flutter/compare/v19.3.0...v19.4.0) (2025-03-04)


### Features

* add automatic retry mechanism for LdSubmit ([8d66475](https://github.com/emdgroup-liquid/liquid-flutter/commit/8d66475c4ba08bf11ae7b5d9efead2565eac2791))


### Bug Fixes

* adjust LdSubmit to use a timer ([e3728f4](https://github.com/emdgroup-liquid/liquid-flutter/commit/e3728f4a9cd634d610f28079d9bb5dd218233149))
* align exception in center ([6cc898d](https://github.com/emdgroup-liquid/liquid-flutter/commit/6cc898d21371227da80eb22f1de3fb62126f8839))
* Ensure existing exception mapper is not overridden when already present ([008a33a](https://github.com/emdgroup-liquid/liquid-flutter/commit/008a33a1b9673796a7fe8e8b48067a9913ca9005))
* exception dialog popping the wrong context ([d3c7023](https://github.com/emdgroup-liquid/liquid-flutter/commit/d3c70233980b37ce44f56f1374ce490c08e7d047))
* reset retryState in final error handling of submit controller ([03262ac](https://github.com/emdgroup-liquid/liquid-flutter/commit/03262acb722e94188186257deb1f0f57716648ea))

## [19.3.0](https://github.com/emdgroup-liquid/liquid-flutter/compare/v19.2.0...v19.3.0) (2025-03-03)


### Features

* add URL handling in LdMasterDetail ([c81cee4](https://github.com/emdgroup-liquid/liquid-flutter/commit/c81cee49d13bc64a532433f4a6022e417dc4612f))
* add URL handling in LdMasterDetail ([8b2f751](https://github.com/emdgroup-liquid/liquid-flutter/commit/8b2f7510573954953fd3a8b97190c6e88a8cbc7c))


### Bug Fixes

* resolve null safety issue by removing unnecessary null check for GoRouter state's pageKey ([97cae06](https://github.com/emdgroup-liquid/liquid-flutter/commit/97cae062d362031870b900f541195a4236491c89))

## [19.2.0](https://github.com/emdgroup-liquid/liquid-flutter/compare/v19.1.0...v19.2.0) (2025-02-20)


### Features

* add "show source code" toggle for demos ([ca3e3ed](https://github.com/emdgroup-liquid/liquid-flutter/commit/ca3e3ed0e37522726ca36e826e1cbd4b9344388f))


### Bug Fixes

* update documentation for ShowSourceCodeOptions and fix source path logic ([675538a](https://github.com/emdgroup-liquid/liquid-flutter/commit/675538a057caa814d0071f32dd1f4da35bdeeee4))

## [19.1.0](https://github.com/emdgroup-liquid/liquid-flutter/compare/v19.0.1...v19.1.0) (2025-02-17)


### Features

* add custom split view predicate to LdMasterDetail ([d7d8afb](https://github.com/emdgroup-liquid/liquid-flutter/commit/d7d8afb3d1f39d25153b955e726ba049e4c4b198))

### [19.0.1](https://github.com/emdgroup-liquid/liquid-flutter/compare/v19.0.0...v19.0.1) (2025-02-12)


### Bug Fixes

* ldAvatar not rendering icons correctly ([fd61608](https://github.com/emdgroup-liquid/liquid-flutter/commit/fd61608c6b801fd6191c35df9d479103c41c39ae))

## [19.0.0](https://github.com/emdgroup-liquid/liquid-flutter/compare/v18.2.0...v19.0.0) (2025-02-10)


### ⚠ BREAKING CHANGES

* Modal changes and screen radius for notifications (#8)

### Features

* Modal changes and screen radius for notifications ([#8](https://github.com/emdgroup-liquid/liquid-flutter/issues/8)) ([53412d1](https://github.com/emdgroup-liquid/liquid-flutter/commit/53412d12ddf72c015cac92253eff9c951927b51a))

## [18.2.0](https://github.com/emdgroup-liquid/liquid-flutter/compare/v18.1.2...v18.2.0) (2025-01-14)


### Features

* adds an option to have a fixed size for dialogs ([211ea7c](https://github.com/emdgroup-liquid/liquid-flutter/commit/211ea7c7860e805a5c5e7e14d5cd303e0d178d10))

### [18.1.2](https://github.com/emdgroup-liquid/liquid-flutter/compare/v18.1.1...v18.1.2) (2025-01-14)


### Bug Fixes

* modal does not affect navigation bar color when LdAppBar is present ([56439a6](https://github.com/emdgroup-liquid/liquid-flutter/commit/56439a69d95a12cfdf1c1ad9c6e34e02b7cf0d21))

### [18.1.1](https://github.com/emdgroup-liquid/liquid-flutter/compare/v18.1.0...v18.1.1) (2025-01-13)


### Bug Fixes

* update modal  corner radius to use the correct paramter ([0dc7edf](https://github.com/emdgroup-liquid/liquid-flutter/commit/0dc7edf2a7dd3b816697ba07976ea3b70375e84b))
* userDismissable with back button ([4a8e90d](https://github.com/emdgroup-liquid/liquid-flutter/commit/4a8e90d879ec2570748abb4d440bb5e7aaeeb9ee))

## [18.1.0](https://github.com/emdgroup-liquid/liquid-flutter/compare/v18.0.2...v18.1.0) (2025-01-13)


### Features

* adaptive modal radius ([21c1ca1](https://github.com/emdgroup-liquid/liquid-flutter/commit/21c1ca1d49547dfd86f5b32c5b8d6ebe290a303c))


### Bug Fixes

* use EdgeInsets for modal insets ([de88b4a](https://github.com/emdgroup-liquid/liquid-flutter/commit/de88b4ad779c547e6fed28fc035e08eaaf601926))

### [18.0.2](https://github.com/emdgroup-liquid/liquid-flutter/compare/v18.0.1...v18.0.2) (2025-01-13)


### Bug Fixes

* add padding to done button in choose modal ([c578583](https://github.com/emdgroup-liquid/liquid-flutter/commit/c578583ffcffb37b4bd90009b1e1a0e0da140c6a))
* adjust contrast for bettter legibility ([80e28ae](https://github.com/emdgroup-liquid/liquid-flutter/commit/80e28aeb71430be3d559d90b95ccff638262794f))
* color for show more text ([86f5eb0](https://github.com/emdgroup-liquid/liquid-flutter/commit/86f5eb05522fca998dc524234ebc51b3f128eebc))
* coloring and action padding in modals ([afbab72](https://github.com/emdgroup-liquid/liquid-flutter/commit/afbab7259698aebf969fab1bcd09f139d98ecd8e))
* consider dark theme for fromCenter calls ([103b8b9](https://github.com/emdgroup-liquid/liquid-flutter/commit/103b8b9125cc6859d9136e28e6a9d6d37d85100b))
* fix background color of modals to be theme.surface ([f84c90a](https://github.com/emdgroup-liquid/liquid-flutter/commit/f84c90ab22798a5be1dacc82a0b2104c85d88238))

### [18.0.1](https://github.com/emdgroup-liquid/liquid-flutter/compare/v18.0.0...v18.0.1) (2025-01-10)

## 18.0.0 (2025-01-10)


### Features

* Initial commit ([d77d6d3](https://github.com/emdgroup-liquid/liquid-flutter/commit/d77d6d36ce56c126ddfd97b3914409110abf137c))

## 18.0.0 (2025-01-10)


### Features

* Initial commit ([d77d6d3](https://github.com/emdgroup-liquid/liquid-flutter/commit/d77d6d36ce56c126ddfd97b3914409110abf137c))

## 18.0.0 (2025-01-09)


### Features

* Initial commit ([d77d6d3](https://github.com/emdgroup-liquid/liquid-flutter/commit/d77d6d36ce56c126ddfd97b3914409110abf137c))

## 18.1.0 (2025-01-09)


### Features

* Initial commit ([d77d6d3](https://github.com/emdgroup-liquid/liquid-flutter/commit/d77d6d36ce56c126ddfd97b3914409110abf137c))

## [18.0.0](https://github.com/emdgroup-liquid/liquid-flutter/compare/v18.1.0...v18.0.0) (2025-01-09)

## 18.1.0 (2025-01-09)


### Features

* Initial commit ([d77d6d3](https://github.com/emdgroup-liquid/liquid-flutter/commit/d77d6d36ce56c126ddfd97b3914409110abf137c))

## 18.0.0 (2025-01-09)


### Features

* Initial commit ([d77d6d3](https://github.com/emdgroup-liquid/liquid-flutter/commit/d77d6d36ce56c126ddfd97b3914409110abf137c))

## [18.0.0-0] 

Initial Apache 2.0 release
