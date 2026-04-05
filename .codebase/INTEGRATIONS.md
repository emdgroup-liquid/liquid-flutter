# External Integrations

## External APIs and Services

| Service | Package | Purpose | Location |
|---------|---------|---------|----------|
| `mtrust_api_guard` | `mtrust_api_guard: ^5.1.0` | API versioning, changelog generation, and API documentation | `apps/example/pubspec.yaml` |

## Database Connections and ORMs

**None** - This is a pure UI component library without direct database connections.

For persistence in consuming applications, `shared_preferences: ^2.5.3` is available in the example app.

## Authentication Providers

**None identified** - No authentication providers (Firebase Auth, Auth0, OAuth, etc.) are used in this component library.

## Routing

- `go_router: ^17.0.1` - Declarative routing used in the example app (`apps/example/`)

## Local Storage

- `shared_preferences: ^2.5.3` - Key-value local storage (example app in `apps/example/pubspec.yaml`)

## Device Integration

- `device_info_plus: ^11.2.0` - Device information retrieval
- `sensors_plus: ^7.0.0` - Device sensor access (accelerometer, gyroscope, etc.)

## CI/CD and Deployment Platform

### GitHub Actions Workflows

| Workflow | Purpose | Location |
|----------|---------|----------|
| `pr_validation.yaml` | PR validation (analyze, test, version check) | `.github/workflows/pr_validation.yaml` |
| `publish_main.yaml` | Publish to pub.dev from main branch | `.github/workflows/publish_main.yaml` |
| `sync_main_to_dev.yaml` | Sync main to dev branch | `.github/workflows/sync_main_to_dev.yaml` |
| `push_main.yaml` | EMD theme publish | `packages/liquid_flutter_emd_theme/.github/workflows/push_main.yaml` |
| `pub_dev.yaml` | EMD theme pub.dev release | `packages/liquid_flutter_emd_theme/.github/workflows/pub_dev.yaml` |
| `pr.yaml` | EMD theme PR validation | `packages/liquid_flutter_emd_theme/.github/workflows/pr.yaml` |

### CI Steps
1. Checkout with Git LFS
2. Flutter installation (stable channel)
3. Melos bootstrap
4. Dart analyzer (`melos exec -- dart analyze`)
5. Flutter tests with coverage (`melos exec -- flutter test --coverage`)
6. `mtrust_api_guard` version checking on changed packages

## Required Environment Variables

**Note**: `.env` files exist in the codebase but were not read per security requirements. Their specific contents are unknown.

Expected environment variables (noted by presence of `.env*` files):
- Environment configuration files may exist for different deployment environments

## Secrets Management

**Forbidden files detected** (not read):
- Any `*.env` files
- Any `credentials.*` files
- Any `*.pem` or `*.key` files
- Any `id_rsa*` files
- Any `serviceAccountKey.json` files

These files exist in the repository but their contents were not examined.

## Platform Channels

- `liquid_flutter_window_utils` uses Pigeon (`^26.1.0`) to generate platform channel code for:
  - Android: `com.liquid.flutter.window_utils.LiquidFlutterWindowUtilsPlugin`
  - macOS: `LiquidFlutterWindowUtilsPlugin`
