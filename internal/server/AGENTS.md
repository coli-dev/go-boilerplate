# AGENTS.md - Server Package

HTTP layer for Go boilerplate. Gin-based with registry pattern for route registration.

---

## STRUCTURE

```
internal/server/
├── auth/         # JWT token generation/verification
├── handlers/     # HTTP handlers with auto-registration
├── middleware/   # CORS, auth, logger, static file serving
├── resp/         # Standardized JSON responses
└── router/       # Route registry pattern
```

---

## ROUTER REGISTRY PATTERN

Routes self-register via `init()` functions. No manual route list needed.

### Registering a Route

```go
func init() {
    router.NewGroupRouter("/api/v1/resource").
        AddRoute(router.NewRoute("/path", http.MethodPost).Handle(handlerFunc))
}
```

### With Middleware

```go
func init() {
    router.NewGroupRouter("/api/v1/protected").
        Use(middleware.Auth()).
        AddRoute(router.NewRoute("/action", http.MethodPost).Handle(handler))
}
```

### Route-per-Route Middleware

```go
router.NewGroupRouter("/api/v1/mixed").
    AddRoute(
        router.NewRoute("/public", http.MethodGet).Handle(publicHandler),
    ).
    AddRoute(
        router.NewRoute("/private", http.MethodGet).
            Use(middleware.Auth()).
            Handle(privateHandler),
    )
```

---

## HANDLER PATTERN

```go
func handlerName(c *gin.Context) {
    var req model.SomeRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        resp.Error(c, http.StatusBadRequest, resp.ErrInvalidJSON)
        return
    }
    
    // Business logic
    result, err := op.SomeOperation(&req)
    if err != nil {
        resp.Error(c, http.StatusInternalServerError, err.Error())
        return
    }
    
    resp.Success(c, result)
}
```

---

## AUTH

### Requiring Auth

Add `middleware.Auth()` to group or route. Retrieves user ID from JWT.

### Accessing User ID

```go
userID := middleware.GetUserID(c)  // Returns uint
```

### JWT Token Format

Client sends: `Authorization: Bearer <token>`

---

## RESPONSE FORMAT

All API responses use standardized wrapper:

```go
// Success
resp.Success(c, data)  // {"code":200,"message":"success","data":...}

// Error
resp.Error(c, http.StatusBadRequest, "message")  // {"code":400,"message":"..."}
```

Built-in error constants in `resp/error.go`:
- `ErrInvalidJSON`, `ErrBadRequest`, `ErrUnauthorized`
- `ErrForbidden`, `ErrNotFound`, `ErrInternalServer`
- `ErrDatabase`

---

## NOTES

- `router.RegisterAll(engine)` called once at startup
- Registry cleared after registration (one-time use)
- Static file middleware serves `web/dist/` with SPA fallback
- Logger middleware uses Zap for structured logging
