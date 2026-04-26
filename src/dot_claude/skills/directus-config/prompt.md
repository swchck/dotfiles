---
name: directus-config
description: Use when building Go applications that sync Directus CMS collection data into application memory, manage Directus schema/flows/ACL programmatically, or need real-time config sync across replicas.
user_invocable: true
---

# directus-config Library Skill

## What This Library Does

`directus-config` (`github.com/swchck/directus-config`) is a Go library that:
- Syncs Directus collection data into type-safe in-memory stores
- Keeps data up-to-date across multiple replicas via polling or WebSocket
- Provides lock-free concurrent reads via `atomic.Pointer`
- Manages Directus schema, ACL, flows, and folders programmatically

## Architecture

```
Directus ──(poll/WS)──► Leader ──(snapshot)──► Postgres
                            │                      │
                            ├──(notify)──► Follower A
                            └──(notify)──► Follower B
```

Leader election uses Postgres advisory locks. Followers sync via Postgres LISTEN/NOTIFY or Redis Pub/Sub.

## Package Overview

| Package | Import | Purpose |
|---------|--------|---------|
| `directus` | `github.com/swchck/directus-config/directus` | HTTP client, schema, ACL, flows, WebSocket |
| `config` | `github.com/swchck/directus-config/config` | In-memory stores, views, translations |
| `manager` | `github.com/swchck/directus-config/manager` | Sync orchestrator |
| `storage` | `github.com/swchck/directus-config/storage` | Postgres snapshot persistence |
| `notify` | `github.com/swchck/directus-config/notify` | Cross-replica notifications |
| `registry` | `github.com/swchck/directus-config/registry` | Instance heartbeat registry |
| `cache` | `github.com/swchck/directus-config/cache` | Redis/memory caching |
| `log` | `github.com/swchck/directus-config/log` | Logger interface + adapters |

## Quick Start Pattern

```go
import (
    "github.com/swchck/directus-config/config"
    "github.com/swchck/directus-config/directus"
    "github.com/swchck/directus-config/manager"
    "github.com/swchck/directus-config/storage"
    "github.com/swchck/directus-config/notify"
    "github.com/swchck/directus-config/registry"
)

// 1. Define Go structs matching Directus collections.
type Product struct {
    ID       int    `json:"id"`
    Name     string `json:"name"`
    Category string `json:"category"`
    Price    int    `json:"price"`
}

// 2. Create in-memory stores.
products := config.NewCollection[Product]("products")
// For singletons: settings := config.NewSingleton[Settings]("settings")

// 3. Create Directus client.
dc := directus.NewClient("https://directus.example.com", "token")

// 4. Wire manager with infrastructure.
pgPool, _ := pgxpool.New(ctx, dbURL)
store := storage.NewPostgresStorage(pgPool)
store.Migrate(ctx)
notif := notify.NewPostgresChannel(pgPool)
reg := registry.NewPostgresRegistry(pgPool)

mgr := manager.New(store, notif, reg, manager.Options{
    PollInterval: 5 * time.Minute,
    ServiceName:  "my-service",
})

// 5. Register configs.
manager.RegisterCollection(mgr, products, directus.NewItems[Product](dc, "products"))

// 6. Start (blocks).
go mgr.Start(ctx)

// 7. Query — lock-free, concurrent-safe.
p, ok := products.Find(func(p Product) bool { return p.ID == 42 })
all := products.All()
count := products.Count()
```

## Directus Client API

### Creating a Client
```go
dc := directus.NewClient(baseURL, token,
    directus.WithLogger(logger),        // optional: dlog.Logger interface
    directus.WithHTTPClient(httpClient), // optional: custom http.Client for middleware
)
```

### Items CRUD (Multi-Item Collections)
```go
items := directus.NewItems[Product](dc, "products")

// List with filtering, sorting, pagination.
products, _ := items.List(ctx,
    directus.WithFilter(directus.And(
        directus.Field("status", "_eq", "published"),
        directus.Field("price", "_gte", 10),
    )),
    directus.WithSort("-price", "name"),
    directus.WithLimit(50),
    directus.WithOffset(0),
    directus.WithFields("id", "name", "price"),
)

// With relational data (M2O, M2M, translations).
products, _ := items.List(ctx,
    directus.WithFields("*", "category.*", "tags.*", "translations.*"),
    directus.WithDeep("translations", directus.RelationQuery{
        Filter: directus.Field("languages_code", "_eq", "en-US"),
    }),
)

// Convenience for translations.
products, _ := items.List(ctx,
    directus.WithTranslations("languages_code", "en-US"),
)

// CRUD.
created, _ := items.Create(ctx, &Product{Name: "New", Price: 10})
updated, _ := items.Update(ctx, "42", &Product{Price: 20})
single, _  := items.Get(ctx, "42")
items.Delete(ctx, "42")

// Version detection (lightweight).
maxTime, _ := items.MaxDateUpdated(ctx)
```

### Singleton CRUD (Single-Item Collections)
```go
s := directus.NewSingleton[Settings](dc, "game_settings")
settings, _ := s.Get(ctx)
updated, _  := s.Update(ctx, &Settings{MaxPlayers: 200})
t, _        := s.DateUpdated(ctx)
```

### Error Handling
```go
_, err := items.Get(ctx, "999")
if errors.Is(err, directus.ErrNotFound) { /* 404 */ }
if errors.Is(err, directus.ErrForbidden) { /* 403 */ }

var re *directus.ResponseError
if errors.As(err, &re) {
    re.StatusCode       // HTTP status
    re.Errors[0].Message // Directus error message
}
```

## In-Memory Config Stores

### Collection[T] — Multiple Items
```go
products := config.NewCollection[Product]("products")

// Read API (lock-free, concurrent-safe).
products.All()                                           // []Product (copy)
products.Count()                                         // int
products.First()                                         // (Product, bool)
products.Find(func(p Product) bool { return p.ID == 42 })  // (Product, bool)
products.FindMany(func(p Product) bool { return p.Price > 100 }) // []Product

// Filter pipeline.
result := products.Filter(
    config.Where(func(p Product) bool { return p.Category == "food" }),
    config.SortBy(func(a, b Product) int { return cmp.Compare(a.Price, b.Price) }),
    config.Offset[Product](10),
    config.Limit[Product](5),
)

// Change hooks.
products.OnChange(func(old, new []Product) {
    fmt.Printf("Updated: %d → %d items\n", len(old), len(new))
})
```

### Singleton[T] — Single Item
```go
settings := config.NewSingleton[Settings]("game_settings")
if s, ok := settings.Get(); ok {
    fmt.Println(s.MaxPlayers)
}
settings.OnChange(func(old, new *Settings) { /* react */ })
```

## Views — Precomputed Auto-Updating Projections

### View[T] — Filtered/Sorted Subset
```go
// Recomputes automatically when source collection changes.
cheapFood := config.NewView("cheap-food", products,
    []config.FilterOption[Product]{
        config.Where(func(p Product) bool { return p.Category == "food" && p.Price < 20 }),
        config.SortBy(func(a, b Product) int { return cmp.Compare(a.Price, b.Price) }),
        config.Limit[Product](100),
    },
    // Optional: persist to Redis for cross-replica sharing.
    config.WithPersistence[Product](cache.NewRedisViewStore(redisClient)),
)

cheapFood.All()   // []Product
cheapFood.Count() // int
cheapFood.Find(func(p Product) bool { return p.ID == 42 })
```

### IndexedView[T, K] — GroupBy
```go
// map[string][]Product grouped by category.
byCategory := config.NewIndexedView("by-cat", products,
    func(p Product) string { return p.Category },
)

byCategory.Get("food")    // []Product
byCategory.Keys()         // []string
byCategory.Count()        // number of unique keys
byCategory.Has("food")    // bool
byCategory.CountFor("food") // number of items
```

### IndexedViewT[T, K, V] — GroupBy + Transform
```go
// map[string][]Level extracted from []Business.
levelsByBiz := config.NewIndexedViewT("levels-by-biz", businesses,
    func(b Business) string { return b.Name },     // key
    func(b Business) []Level { return b.Levels },   // values
)

levelsByBiz.Get("Pizza Place") // []Level
```

### RelatedView[T, R] — Flattened M2M/O2M
```go
allTags := config.NewRelatedView("all-tags", products,
    func(p Product) []Tag { return p.Tags },
    config.WithDedup[Product, Tag](func(a, b Tag) bool { return a.ID == b.ID }),
)

allTags.All()   // []Tag (deduplicated across all products)
allTags.Count() // total unique tags
```

### TranslatedView[T, R] — Per-Language Flattening
```go
enProducts := config.NewTranslatedView("products-en", products,
    func(p Product) LocalizedProduct {
        tr, _ := config.FindTranslation(p.Translations,
            func(t Translation) string { return t.LanguagesCode },
            "en-US",
        )
        return LocalizedProduct{ID: p.ID, Name: tr.Name}
    },
)
```

### Translation Helpers
```go
// Find single translation.
tr, ok := config.FindTranslation(translations, langFn, "en-US")

// With fallback chain.
tr, ok := config.FindTranslationWithFallback(translations, langFn, "de-DE", "en-US", "en")

// As map.
trMap := config.TranslationMap(translations, langFn) // map[string]Translation
```

## Manager — Sync Orchestrator

### Configuration
```go
mgr := manager.New(store, notifier, reg,
    manager.Options{
        PollInterval:             5 * time.Minute,
        HeartbeatInterval:        10 * time.Second,
        WaitConfirmationsTimeout: 30 * time.Second,
        AdvisoryLockKey:          987654321,
        WSPollInterval:           15 * time.Minute,
        ServiceName:              "my-service",
    },
    manager.WithLogger(logger),
    manager.WithCache(redisCache, cache.ReadWriteThrough),
    manager.WithWebSocket(wsClient),
    manager.WithInstanceID("custom-id"),
)
```

### Registration
```go
// Package-level generic functions (Go doesn't allow generic methods on non-generic receivers).
manager.RegisterCollection(mgr, products, directus.NewItems[Product](dc, "products"),
    directus.WithFields("*", "translations.*"), // applied to every fetch
)
manager.RegisterSingleton(mgr, settings, directus.NewSingleton[Settings](dc, "settings"))
```

### Lifecycle
```go
go mgr.Start(ctx)  // blocks until ctx cancelled
mgr.SyncNow(ctx)   // force immediate sync
mgr.Stop()          // graceful shutdown
```

## WebSocket Real-Time Sync

```go
ws := directus.NewWSClient("https://directus.example.com", "token",
    directus.WithWSLogger(logger),
)
defer ws.Close()

// Simple subscription.
events, _ := ws.Subscribe(ctx, "products", "settings")

// Advanced subscription with specific fields.
events, _ := ws.SubscribeWith(ctx,
    directus.WSSubscription{
        Collection: "products",
        Query: &directus.SubscriptionQuery{
            Fields: []string{"*", "translations.*"},
            Event:  []string{"create", "update"},
        },
    },
)

// Integrate with manager for automatic sync.
mgr := manager.New(store, notif, reg, opts,
    manager.WithWebSocket(ws),
)
```

## Schema Management

### Collections
```go
// Create collection with properly configured UI fields.
dc.CreateCollection(ctx, directus.CreateCollectionInput{
    Collection: "products",
    Meta:       &directus.CollectionMeta{Icon: "shopping_cart", Group: "ecommerce"},
    Fields: []directus.FieldInput{
        directus.PrimaryKeyField("id"),
        directus.DateCreatedField(),
        directus.DateUpdatedField(),
        directus.StatusField(),
        directus.StringField("name"),
        directus.IntegerField("price"),
        directus.BooleanField("active"),
        directus.M2OField("category_id", "categories"),
    },
})

// Collection folders.
dc.CreateCollectionFolder(ctx, "ecommerce", &directus.CollectionMeta{
    Icon: "storefront", Collapse: directus.CollapseOpen,
})
dc.MoveCollectionToFolder(ctx, "products", "ecommerce")
```

### Relations
```go
// M2O: product → category.
dc.CreateRelation(ctx, directus.M2O("products", "category_id", "categories"))

// O2M: category → products (alias).
dc.CreateRelation(ctx, directus.O2M("categories", "products", "products", "category_id"))

// M2M: products ↔ tags (via junction).
source, target := directus.M2M(directus.M2MInput{
    Collection: "products", Related: "tags",
    JunctionCollection: "products_tags",
    JunctionSourceField: "products_id", JunctionTargetField: "tags_id",
    AliasField: "tags",
})
dc.CreateRelation(ctx, source)
dc.CreateRelation(ctx, target)

// Translations.
src, lang := directus.Translations("products", "products_translations",
    "products_id", "languages_code", "languages")
dc.CreateRelation(ctx, src)
dc.CreateRelation(ctx, lang)
```

### Field Helpers
All field helpers set proper `meta.interface` and `meta.display` so fields render correctly in the Directus UI (not "Database Only"):

| Helper | Interface | Use Case |
|--------|-----------|----------|
| `PrimaryKeyField(name)` | `input` | Auto-increment integer PK |
| `UUIDPrimaryKeyField(name)` | `input` | UUID PK |
| `StringField(name)` | `input` | Text input |
| `TextField(name)` | `input-multiline` | Textarea |
| `IntegerField(name)` | `input` | Number input |
| `FloatField(name)` / `DecimalField(name)` | `input` | Decimal input |
| `BooleanField(name)` | `boolean` | Toggle switch |
| `JSONField(name)` | `input-code` | Code editor |
| `M2OField(name, related)` | `select-dropdown-m2o` | Relational dropdown with search + create |
| `StatusField()` | `select-dropdown` | Draft/Published/Archived |
| `DateCreatedField()` | `datetime` | Auto-populated on create |
| `DateUpdatedField()` | `datetime` | Auto-populated on update |
| `SortField()` | `input` | Drag-and-drop ordering |

## Flows (Automation)

```go
// Create a hook flow.
flow, _ := dc.CreateFlow(ctx, directus.NewHookFlow("On Product Create",
    directus.HookFlowOptions{
        Type: "action", Scope: []string{"items.create"}, Collections: []string{"products"},
    },
))

// Add operations.
logOp, _ := dc.CreateOperation(ctx, directus.Operation{
    Name: "Log", Key: "log_it", Type: directus.OpLog,
    Flow: flow.ID, Options: map[string]any{"message": "Product created"},
})

// Link flow to first operation.
dc.UpdateFlow(ctx, flow.ID, directus.Flow{Operation: &logOp.ID})

// Flow builders: NewHookFlow, NewWebhookFlow, NewScheduleFlow, NewManualFlow
// Operation builders: NewLogOperation, NewRequestOperation, NewCreateItemOperation, NewConditionOperation
```

## ACL Management

```go
dc.GrantAdminAccess(ctx) // Fix Directus 11 admin policy
dc.GrantFullAccess(ctx, policyID, "products") // CRUD permissions on collection

role, _ := dc.CreateRole(ctx, directus.Role{Name: "Editor"})
policy, _ := dc.CreatePolicy(ctx, directus.Policy{Name: "Editor Policy", AppAccess: true})
user, _ := dc.GetCurrentUser(ctx)
```

## Caching

### Strategies
| Strategy | Reads | Writes | Async | Use |
|----------|-------|--------|-------|-----|
| `ReadThrough` | yes | no | - | Fast cold starts |
| `WriteThrough` | no | yes | no | Guaranteed freshness |
| `WriteBehind` | no | yes | yes | Lower latency |
| `ReadWriteThrough` | yes | yes | no | Production default |

### View Persistence
```go
// Redis — cross-replica sharing.
redisStore := cache.NewRedisViewStore(redisClient, cache.WithViewTTL(10*time.Minute))
view := config.NewView("food", products, filters, config.WithPersistence[Product](redisStore))

// In-memory — warm start within process.
memStore := cache.NewMemoryViewStore()
view := config.NewView("food", products, filters, config.WithPersistence[Product](memStore))
```

## Logging

The library uses a `log.Logger` interface — no dependency on any specific logger.

```go
import dlog "github.com/swchck/directus-config/log"

// Zerolog.
logger := dlog.NewZerolog(zerolog.New(os.Stderr))

// Standard library slog.
logger := dlog.NewSlog(slog.Default())

// Uber Zap.
logger := dlog.NewZap(zapLogger)

// No-op (default).
logger := dlog.Nop()

// Pass to any component.
directus.WithLogger(logger)
manager.WithLogger(logger)
notify.WithPGLogger(logger)
```

## Infrastructure Packages

### Storage (Postgres)
```go
store := storage.NewPostgresStorage(pgPool)
store.Migrate(ctx) // creates config_snapshots, config_apply_log, config_instances tables
```

### Notify (Cross-Replica)
```go
// Postgres LISTEN/NOTIFY.
notif := notify.NewPostgresChannel(pgPool, notify.WithPGLogger(logger))

// Redis Pub/Sub.
notif := notify.NewRedisChannel(redisClient, notify.WithRedisLogger(logger))
```

### Registry (Instance Heartbeat)
```go
reg := registry.NewPostgresRegistry(pgPool,
    registry.WithStaleThreshold(30 * time.Second),
)
```

## Key Design Rules

1. **All reads are lock-free** via `atomic.Pointer` — zero contention for concurrent access
2. **Views update synchronously** in the OnChange hook chain — by the time `Swap()` returns, all derived views are up-to-date
3. **Persistence is async** — Redis/memory writes never block reads or swaps
4. **No panics** — user callback panics are recovered and returned as errors
5. **Leader/follower** — only the leader fetches from Directus; followers receive data via notify channel
6. **WebSocket forced sync** — skips version comparison since the WS already confirms a change occurred

## Directus 11 Quirks to Know

- Fields with `special` metadata (`date-created`, `date-updated`) must be created SEPARATELY after the collection — `CreateCollection` handles this automatically
- `ADMIN_TOKEN` static token doesn't inherit policy changes; use JWT login for admin operations
- WebSocket sends `{"type":"ping"}` and expects `{"type":"pong"}` — the library handles this automatically
- `schema` field must be `{}` (not omitted) for table collections; `null` for folder collections
