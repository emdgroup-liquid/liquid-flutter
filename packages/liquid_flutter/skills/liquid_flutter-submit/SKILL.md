---
name: liquid_flutter-submit
description: Use when implementing async operations, form submissions, loading states, error handling, or retry logic in Liquid Flutter — covers LdSubmit widget, builders, LdSubmitController, LdExceptionMapper, and related patterns.
---

# LdSubmit — Async Operations in Liquid Flutter

`LdSubmit` is the primary widget for handling asynchronous operations that might fail. It manages loading states, error handling, retries, and result display automatically.

## When to Use LdSubmit

Use `LdSubmit` whenever you have:
- An async operation triggered by user action (button tap, form submit)
- An async operation that runs on mount (loading data)
- Operations that might fail and need error handling
- Operations that benefit from retry logic

**✅ Use LdSubmit:**
- Form submissions
- API calls triggered by buttons
- Loading data on page mount
- File uploads/downloads
- Any operation that can fail

**❌ Don't use LdSubmit:**
- Simple state updates (use `setState`)
- Operations that never fail (use regular async/await)
- Background tasks that don't need UI feedback

## Basic Usage

```dart
class LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LdSubmit<User, LoginCredentials>(
      arg: credentials,
      config: LdSubmitConfig<User, LoginCredentials>(
        action: (credentials) async {
          // Services are accessed via closures or passed as arguments
          // For stateless services, access directly:
          return await ApiService.instance.login(
            credentials!.email,
            credentials.password,
          );
        },
        submitText: 'Login',
        loadingText: 'Logging in...',
      ),
      child: LdSubmitInlineBuilder<User, LoginCredentials>(
        resultBuilder: (context, user, controller) {
          return LdText.p('Welcome, ${user.name}!');
        },
      ),
    );
  }
}
```

Note: the builder is passed as the **`child:`** parameter (not `builder:`).

## Builders

`LdSubmit` uses builders to determine how to display different states:

1. **LdSubmitInlineBuilder**: Displays loading/error inline (default, best for forms)
2. **LdSubmitCenteredBuilder**: Centers loading/error states (best for page loads)
3. **LdSubmitDialogBuilder**: Shows loading/error in a dialog (blocks interaction)
4. **LdSubmitNotificationBuilder**: Shows loading/error as notifications (non-blocking)

```dart
// Inline (default) - for forms
LdSubmit<User, void>(
  config: LdSubmitConfig<User, void>(action: (_) => fetchUser()),
  child: LdSubmitInlineBuilder<User, void>(),
)

// Centered - for page loads
LdSubmit<User, void>(
  config: LdSubmitConfig<User, void>(action: (_) => fetchUser()),
  child: LdSubmitCenteredBuilder<User, void>(),
)

// Dialog - blocks interaction
LdSubmit<User, void>(
  config: LdSubmitConfig<User, void>(action: (_) => fetchUser()),
  child: LdSubmitDialogBuilder<User, void>(),
)
```

## Auto-Triggering

Use `autoTrigger: true` for operations that should run immediately when the widget mounts:

```dart
LdSubmit<List<Post>, void>(
  config: LdSubmitConfig<List<Post>, void>(
    autoTrigger: true, // Runs on mount
    action: (_) async {
      return await ApiService.instance.getPosts();
    },
  ),
  child: LdSubmitCenteredBuilder<List<Post>, void>(
    resultBuilder: (context, posts, controller) {
      return PostsList(posts: posts);
    },
  ),
)
```

## Passing Arguments

Pass arguments that change over time:

```dart
class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return LdAutoSpace(
      children: [
        LdInput(
          label: 'Search',
          onChanged: (value) => setState(() => _query = value),
        ),
        LdSubmit<List<Result>, String>(
          arg: _query, // Passes query to action
          config: LdSubmitConfig<List<Result>, String>(
            action: (query) async {
              if (query == null || query.isEmpty) {
                return [];
              }
              return await ApiService.instance.search(query);
            },
          ),
          child: LdSubmitInlineBuilder<List<Result>, String>(
            resultBuilder: (context, results, controller) {
              return ResultsList(results: results);
            },
          ),
        ),
      ],
    );
  }
}
```

## Retry Configuration

Configure automatic retries with exponential backoff:

```dart
LdSubmit<User, void>(
  config: LdSubmitConfig<User, void>(
    action: (_) => fetchUser(),
    retryConfig: LdRetryConfig.defaultAutomaticRetries(),
    // Or customize:
    // retryConfig: LdRetryConfig(
    //   maxAttempts: 3,
    //   baseDelay: Duration(seconds: 1),
    // ),
  ),
  child: LdSubmitCenteredBuilder<User, void>(),
)
```

## Using LdSubmitController

For programmatic control, use `LdSubmitController`. Note that this is usually not necessary — prefer using a custom builder that reads the controller from the `LdSubmit` widget instead, as managing the controller adds code and complexity.

When a `controller:` is passed to `LdSubmit`, the widget's own `arg` parameter is ignored — pass `arg` to the controller directly instead.

```dart
class OrderForm extends StatefulWidget {
  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  late final LdSubmitController<Order, OrderData> _controller;

  @override
  void initState() {
    super.initState();
    _controller = LdSubmitController<Order, OrderData>(
      config: LdSubmitConfig<Order, OrderData>(
        action: (data) => createOrder(data!),
      ),
    );
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LdSubmit<Order, OrderData>(
      controller: _controller,
      child: LdSubmitInlineBuilder<Order, OrderData>(
        resultBuilder: (context, order, controller) {
          return LdText.p('Order created: ${order.id}');
        },
      ),
    );
  }
}
```

## Error Handling

`LdSubmit` automatically handles exceptions and displays them using `LdExceptionView`. Exceptions are mapped to user-friendly messages via `LdExceptionLocalizer`.

**✅ Recommended: Throw regular exceptions and use LdExceptionLocalizer**

The default mapper handles common exceptions (`SocketException`, `TimeoutException`, `FormatException`) automatically. For custom exceptions, wrap with `LdExceptionLocalizer`:

```dart
// In your app root or feature widget
Widget build(BuildContext context) {
  return LdExceptionLocalizer(
    onException: (context, e) {
      // e is LdException, e.exception is the original thrown exception
      if (e.exception is NetworkException) {
        return LdLocalizedException(
          message: 'Network error',
          moreInfo: 'Please check your internet connection',
        );
      }
      if (e.exception is AuthenticationException) {
        return LdLocalizedException(
          message: 'Not authenticated',
          canRetry: false,
        );
      }
      // Return null to use default mapper
      return null;
    },
    child: LdSubmit<User, void>(
      config: LdSubmitConfig<User, void>(
        action: (_) async {
          // Just throw regular exceptions - localizer handles them
          return await ApiService.instance.getUser();
        },
      ),
      child: LdSubmitInlineBuilder<User, void>(),
    ),
  );
}
```

**❌ Not recommended: Throwing LdLocalizedException directly**

```dart
// Don't do this - use LdExceptionLocalizer instead
throw LdLocalizedException(
  message: 'Network error',
  moreInfo: 'Please check your internet connection',
);
```

The localizer approach centralizes error handling, makes exceptions easier to test, and allows for consistent error messages across your app.

## Service Access Patterns

When accessing services in `LdSubmit` actions, follow these patterns:

```dart
// ✅ Good: Service access in action (stateless services) or via closures
class OrderForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Lookup stateful services in build method
    final orderService = context.read<OrderService>();
    final authService = context.read<AuthService>();
    
    return LdSubmit<Order, OrderData>(
      config: LdSubmitConfig<Order, OrderData>(
        action: (data) async {
          // Access services via closure
          if (!authService.isAuthenticated) {
            throw LdLocalizedException(message: 'Not authenticated');
          }
          
          // For stateless services, access directly
          return await ApiService.instance.createOrder(data!);
        },
      ),
      child: LdSubmitInlineBuilder<Order, OrderData>(),
    );
  }
}
```

**Key Points:**
- Lookup stateful services (Provider-based) in the `build` method and access them via closures
- Access stateless services (singletons) directly in the action
- Never store service references in service classes — always lookup via context at evaluation time

## Best Practices

1. **Always use LdSubmit for async operations** that might fail
2. **Use inline builder for forms**, centered for page loads
3. **Use autoTrigger** for operations that should run on mount
4. **Configure retries** for network operations that might temporarily fail
5. **Use LdExceptionLocalizer** for error handling — throw regular exceptions and let the localizer handle mapping to user-friendly messages
