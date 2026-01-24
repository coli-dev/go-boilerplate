# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run Commands

### Backend (Go)
- **Hot reload**: `air` (requires `go install github.com/air-verse/air@latest`)
- **Run directly**: `go run . start`
- **Build**: `./scripts/build.sh` (supports `build <os> <arch>` and `release` targets)

### Frontend (web/)
- **Dev server**: `npm run dev`
- **Build**: `npm run build`
- **Lint**: `npm run lint`
- **Format**: `npm run format`

## Architecture

### Backend
The backend is a Gin-based HTTP server with Cobra CLI, structured as:

- `cmd/` - CLI commands (start, version)
- `internal/conf/` - Viper-based config, creates `data/config.json` on first run
- `internal/db/` - GORM + SQLite database initialization
- `internal/model/` - Data models with request/response DTOs
- `internal/op/` - Business logic operations
- `internal/server/` - HTTP layer:
  - `auth/` - JWT generation and verification
  - `handlers/` - Route handlers using auto-registration via `init()`
  - `middleware/` - CORS, logger, auth, static file serving
  - `router/` - Route registry pattern with `NewGroupRouter` and `NewRoute`
  - `resp/` - Standardized response helpers (`resp.Success`, `resp.Error`)

### Frontend
React + TypeScript + Vite SPA in `web/`. Uses Tailwind CSS and Biome for linting. Built assets in `web/dist` are served by the backend with SPA fallback.

## Key Patterns

**Route registration**: Handlers register routes in `init()` using the router registry:
```go
router.NewGroupRouter("/api/v1/user").
    AddRoute(router.NewRoute("/login", http.MethodPost).Handle(login))
```

**Auth middleware**: Extracts JWT from `Authorization` header, stores user ID in Gin context.

**Config**: Viper with env override prefix `EXAMPLE_`. Config file at `data/config.json`.
