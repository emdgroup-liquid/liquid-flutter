import 'package:flutter/material.dart';
import 'package:liquid/code_block.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class MonkeyBackendDemo extends StatelessWidget {
  const MonkeyBackendDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/patterns/monkey_backend.dart",
      category: "Patterns",
      title: "LdMonkey - Backend API",
      demo: LdAutoSpace(
        children: [
          LdText.h("Backend API Compatibility"),
          LdText.p(
            "This page describes the server-side contract your backend must satisfy to work seamlessly with LdMonkey. "
            "The fetchListWithParameters callback is just a Dart async function — it can call any API (REST, GraphQL, gRPC) — "
            "but these conventions keep the client's pagination cache, optimistic updates, and URL state correct.",
          ),

          // ── 1. Pagination ────────────────────────────────────────────────
          LdText.hs("1. Pagination"),
          LdText.p(
            "The client always requests pages by offset and page size. Your list endpoint must accept both and return a total count.",
          ),
          CodeBlock(
            language: "http",
            code: "GET /tasks?offset=0&limit=20\nGET /tasks?offset=20&limit=20",
          ),
          LdText.p("Required response shape:"),
          CodeBlock(
            language: "json",
            code: '{\n'
                '  "items": [ ... ],\n'
                '  "total": 247,\n'
                '  "hasMore": true\n'
                '}',
          ),
          LdCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                LdListItem(
                  title: Text("items"),
                  subtitle: Text("The items for this page only."),
                  trailing: LdTag.warning(child: Text("required")),
                ),
                LdListItem(
                  title: Text("total"),
                  subtitle: Text(
                    "Global count across ALL pages for the active filter/sort. "
                    "The client uses this for the sparse item cache and item counter — never omit it.",
                  ),
                  trailing: LdTag.warning(child: Text("required")),
                ),
                LdListItem(
                  title: Text("hasMore"),
                  subtitle: Text(
                    "false terminates greedy loading immediately. Must equal offset + limit < total.",
                  ),
                  trailing: LdTag.warning(child: Text("required")),
                ),
                LdListItem(
                  title: Text("nextPageToken"),
                  subtitle: Text(
                    "Optional. Return a cursor string for token-based pagination. "
                    "The client stores it and passes it back as pageToken on the next request. "
                    "total must still be accurate when using cursor pagination.",
                  ),
                  trailing: LdTag.success(child: Text("optional")),
                ),
              ],
            ),
          ),
          LdText.p(
            "Page size is configured via LdCallbackModel(pageSize: N) and defaults to 10. "
            "Accept any reasonable value (10–100). Never hard-code a server-side page size that differs from the client's.",
          ),

          // ── 2. Filtering ─────────────────────────────────────────────────
          LdText.hs("2. Filtering"),
          LdText.p(
            "Each active filter serializes to query parameters. Filters with no active value are not sent — treat a missing parameter as 'no filter applied'.",
          ),
          LdCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                LdListItem(
                  title: Text("LdFilterBool"),
                  subtitle: Text("name=true (only sent when on)"),
                  trailing: LdTag(child: Text("?completed=true")),
                ),
                LdListItem(
                  title: Text("LdFilterSearch"),
                  subtitle: Text("name=<text>"),
                  trailing: LdTag(child: Text("?search=flutter")),
                ),
                LdListItem(
                  title: Text("LdFilterOneOf"),
                  subtitle: Text("name=<value>"),
                  trailing: LdTag(child: Text("?status=active")),
                ),
                LdListItem(
                  title: Text("LdFilterAnyOf"),
                  subtitle: Text("name=<v1,v2,v3> (comma-separated)"),
                  trailing: LdTag(child: Text("?tags=bug,urgent")),
                ),
                LdListItem(
                  title: Text("LdFilterRange"),
                  subtitle: Text("name=<start>,<end>"),
                  trailing: LdTag(child: Text("?price=10.5,99.0")),
                ),
              ],
            ),
          ),
          LdText.p(
            "All active filters are ANDed server-side. "
            "The total in the response must reflect the filtered count, not the unfiltered total. "
            "Filters must be pure: the same params + same data always return the same result, "
            "since the client caches pages keyed by filter state.",
          ),

          // ── 3. Sorting ───────────────────────────────────────────────────
          LdText.hs("3. Sorting"),
          LdText.p(
            "Sort options are serialized as name-direction strings. Multiple active sorts are sent as repeated params.",
          ),
          CodeBlock(
            language: "http",
            code: "GET /tasks?sort=dueDate-asc\nGET /tasks?sort=priority-asc&sort=dueDate-asc",
          ),
          LdAutoSpace(
            children: [
              LdText.p(
                "When the sort param is absent, apply a stable default order (e.g. id ASC). "
                "Never return random order — the client's offset cache assumes stable ordering.",
              ),
              LdText.p(
                "Always append a stable tie-breaker (ORDER BY …, id ASC) so pages don't shift when the primary sort key is non-unique.",
              ),
            ],
          ),

          // ── 4. Get by id ─────────────────────────────────────────────────
          LdText.hs("4. Get by id"),
          LdText.p(
            "Called when a detail panel opens, on deep-link restore, and after create to confirm the new item. "
            "Must return 404 when the item does not exist.",
          ),
          CodeBlock(language: "http", code: "GET /tasks/42\n→ 200 { ...item... }  or  404"),

          // ── 5. Get offset by id ───────────────────────────────────────────
          LdText.hs("5. Get offset by id (strongly recommended)"),
          LdText.p(
            "This endpoint is the single highest-impact optional addition. "
            "It lets the client scroll smoothly to a newly created or updated item without a full list refresh.",
          ),
          CodeBlock(
            language: "http",
            code: "GET /tasks/offset-of/42?completed=true&sort=dueDate-asc\n"
                "→ 200 { \"offset\": 17 }\n\n"
                "# Item not in current view (filtered out / deleted):\n"
                "→ 200 { \"offset\": -1 }  or  404",
          ),
          LdText.p(
            "Accept the same filter and sort params as the list endpoint. "
            "Return the 0-based index of the item in that result set.",
          ),
          LdCard(
            child: LdAutoSpace(
              children: [
                LdText.ps("Without this endpoint:"),
                LdText.p(
                  "After creating an item the list resets to page 0 and scrolls to top. "
                  "After an update that changes sort order, the list fully refreshes.",
                ),
                LdText.ps("With this endpoint:"),
                LdText.p(
                  "The new item animates in at its correct sorted position. "
                  "Updates reposition the row inline with no visible flicker.",
                ),
              ],
            ),
          ),

          // ── 6. Mutation endpoints ────────────────────────────────────────
          LdText.hs("6. Mutation endpoints"),
          LdText.p(
            "Mutations follow standard REST patterns. The key requirement is the response shape.",
          ),
          CodeBlock(
            language: "http",
            code: "# Create — return the server-confirmed item\n"
                "POST /tasks\n"
                "→ 201 { ...full item with server-assigned id, timestamps... }\n\n"
                "# Update — return the full updated item\n"
                "PATCH /tasks/42\n"
                "→ 200 { ...full updated item... }\n"
                "# (204 No Content is accepted; optimistic value is kept)\n\n"
                "# Delete\n"
                "DELETE /tasks/42\n"
                "→ 204 No Content\n\n"
                "# Batch delete (strongly recommended for lists > ~20 items)\n"
                "DELETE /tasks/batch\n"
                "Body: { \"ids\": [42, 43, 44] }\n"
                "→ 204 No Content",
          ),
          LdText.p(
            "If you omit the batch delete endpoint, set deleteBatchFn to null in LdCallbackModel "
            "and the client falls back to sequential single-item deletes.",
          ),

          // ── 7. Error handling ────────────────────────────────────────────
          LdText.hs("7. Error handling"),
          LdText.p(
            "Return standard HTTP status codes. Include a machine-readable body so LdExceptionMapper "
            "can surface friendly messages.",
          ),
          CodeBlock(
            language: "json",
            code: '{ "error": "validation_failed", "message": "Title is required" }',
          ),
          LdCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                LdListItem(
                  title: Text("400"),
                  subtitle: Text("Validation error — shown to user from response body"),
                ),
                LdListItem(
                  title: Text("401"),
                  subtitle: Text("Auth error — intercept via LdExceptionMapper"),
                ),
                LdListItem(
                  title: Text("404"),
                  subtitle: Text("Not found — shown in detail panel"),
                ),
                LdListItem(
                  title: Text("409"),
                  subtitle: Text("Conflict — useful for optimistic update rollback signals"),
                ),
                LdListItem(
                  title: Text("5xx"),
                  subtitle: Text("Generic error state with retry"),
                ),
              ],
            ),
          ),

          // ── 8. Caching notes ─────────────────────────────────────────────
          LdText.hs("8. Caching & total accuracy"),
          LdText.p(
            "The client caches list pages by a key derived from active filters and sort options. "
            "This means total must be consistent across pages for the same query. "
            "If concurrent mutations change the count mid-session, prefer a snapshot count that is stable per request session.",
          ),
          LdText.p(
            "The client automatically invalidates its cache on any CRUD mutation "
            "(autoInvalidateCacheOnMutation: true by default). You do not need to push invalidation from the server.",
          ),

          // ── 9. Checklist ─────────────────────────────────────────────────
          LdText.hs("9. Compatibility checklist"),
          LdCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _CheckItem("List endpoint accepts offset and limit as query params"),
                _CheckItem("Response includes items, total, and hasMore"),
                _CheckItem("total reflects the filtered count"),
                _CheckItem("Filter params are optional; absent = unfiltered"),
                _CheckItem("Multiple active filters are ANDed server-side"),
                _CheckItem("Sort param is optional; absent = stable default order"),
                _CheckItem("Sort always has a stable tie-breaker (e.g. id ASC)"),
                _CheckItem("GET /resource/:id returns 404 when not found"),
                _CheckItem("GET /resource/offset-of/:id exists (strongly recommended)"),
                _CheckItem("Create returns 201 with the full confirmed item"),
                _CheckItem("Update returns 200 with the full updated item"),
                _CheckItem("Delete returns 204"),
                _CheckItem("Batch delete endpoint exists for lists > ~20 items"),
              ],
            ),
          ),

          // ── 10. GraphQL note ─────────────────────────────────────────────
          LdText.hs("10. GraphQL / non-REST APIs"),
          LdText.p(
            "fetchListWithParameters is just a Dart async function — it can call any transport. "
            "For GraphQL, map params.offset + params.pageSize to first / skip (or after cursor), "
            "and map params.filters and params.sortOptions to GraphQL variables. "
            "The same compatibility principles (stable total, stable order, offset support) apply regardless of transport.",
          ),
          CodeBlock(
            language: "dart",
            code: "fetchListWithParameters: (params) async {\n"
                "  final result = await graphqlClient.query(\n"
                "    QueryOptions(\n"
                "      document: gql(tasksQuery),\n"
                "      variables: {\n"
                "        'offset': params.offset,\n"
                "        'limit': params.pageSize,\n"
                "        'search': params.filters\n"
                "            .whereType<LdFilterSearch>()\n"
                "            .firstOrNull?.searchText,\n"
                "        'sort': params.sortOptions\n"
                "            .map((s) => '\${s.name}-\${s.direction.name}')\n"
                "            .toList(),\n"
                "      },\n"
                "    ),\n"
                "  );\n"
                "  final data = result.data!['tasks'];\n"
                "  return LdListPage(\n"
                "    newItems: (data['nodes'] as List).map(Task.fromJson).toList(),\n"
                "    total: data['totalCount'] as int,\n"
                "    hasMore: data['pageInfo']['hasNextPage'] as bool,\n"
                "  );\n"
                "},",
          ),
        ],
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String text;
  const _CheckItem(this.text);

  @override
  Widget build(BuildContext context) {
    return LdListItem(
      leading: Icon(
        Icons.check_box_outline_blank,
        size: 18,
        color: LdTheme.of(context).textMuted,
      ),
      title: Text(text),
    );
  }
}
