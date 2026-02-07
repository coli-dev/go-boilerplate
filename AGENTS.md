# AGENTS.md - Go Boilerplate

Full-stack boilerplate: Go backend (Gin + GORM + Cobra) + Next.js frontend.

---

## STRUCTURE

```
.
├── cmd/                    # Cobra CLI commands
├── internal/               # Backend internals
│   ├── conf/               # Viper config (auto-creates data/config.json)
│   ├── db/                 # GORM + SQLite initialization
│   ├── model/              # Data models + request/response DTOs
│   ├── op/                 # Business operations
│   ├── server/             # HTTP layer (see internal/server/AGENTS.md)
│   │   ├── auth/           # JWT generation/verification
│   │   ├── handlers/       # Route handlers (auto-registration)
│   │   ├── middleware/     # CORS, auth, logger, static
│   │   ├── resp/           # Standardized JSON responses
│   │   └── router/         # Registry pattern
│   └── utils/              # shutdown, log
├── scripts/                # Build & Docker scripts
├── static/                 # Static files
└── web/                    # Next.js frontend (see web/AGENTS.md)
    ├── src/app/            # App Router pages
    └── src/components/     # shadcn/ui components
```

---

## COMMANDS

### Full Stack Development
```bash
make dev          # Backend + frontend hot reload
```

### Backend Only
```bash
air               # Hot reload with Air
go run . start    # Direct run
./scripts/build.sh [os] [arch]   # Cross-compile
```

### Frontend Only
```bash
cd web
npm run dev       # Next.js + Turbopack
npm run build     # Production build → dist/
npm run lint      # Biome check
npm run format    # Biome format
```

---

## CONVENTIONS

### Backend

**Route Registration** - Auto-register via `init()`:
```go
func init() {
    router.NewGroupRouter("/api/v1/resource").
        AddRoute(router.NewRoute("/path", http.MethodPost).Handle(handler))
}
```

**Models** - Separate struct for DB + DTOs:
```go
type User struct { /* GORM fields */ }
type UserLogin struct { /* JSON tags */ }
```

**Operations** - Business logic in `op/` package:
```go
var ErrUserNotFound = errors.New("user not found")
func UserGetByID(id uint) (*model.User, error)
```

**Responses** - Standardized helpers:
```go
resp.Success(c, data)     // {"code":200,"message":"success","data":...}
resp.Error(c, 400, msg)   // {"code":400,"message":"..."}
```

### Frontend

**Components** - shadcn/ui pattern with `cn()` utility
**API Calls** - Direct fetch to `/api/v1/*`, store token in localStorage
**Linting** - Biome (replaces ESLint + Prettier)

---

## CONFIGURATION

Viper-based with env override prefix `GOBOILERPLATE_`:
- `GOBOILERPLATE_SERVER_PORT=3000`
- `GOBOILERPLATE_DATABASE_PATH=./data.db`

Config file auto-created at `data/config.json` on first run.

---

## WHERE TO LOOK

| Task | Location |
|------|----------|
| Add API endpoint | `internal/server/handlers/*.go` |
| Change JWT logic | `internal/server/auth/` |
| Add middleware | `internal/server/middleware/` |
| Modify response format | `internal/server/resp/` |
| Add DB model | `internal/model/` |
| Business logic | `internal/op/` |
| Frontend pages | `web/src/app/` |
| UI components | `web/src/components/ui/` |

---

## NOTES

- Backend serves `web/dist/` with SPA fallback for production
- Static files in `static/` served at root
- Frontend proxies API calls to backend in dev mode
- JWT expires: default 15min, custom via `expire` field, `-1` = 30 days
- Environment variable `GOBOILERPLATE_DEBUG=true` enables debug mode
