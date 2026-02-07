# GoBoilerplate

A Go web service boilerplate with Gin, Cobra CLI, and GORM.

## Requirements

- Go 1.24+
- Node.js 20+
- [Air](https://github.com/air-verse/air) (for hot reload during development)

## Quick Start

```bash
go install github.com/air-verse/air@latest
cd web && npm install && cd ..
make dev
```

Open http://localhost:3000 - both frontend and backend hot reload on code changes.

## Development

### Full Stack Dev (Recommended)

```bash
make dev
```

Runs both backend (Air) and frontend (Next.js) with hot reload. Frontend at `http://localhost:3000` proxies API calls to backend at `http://localhost:8080`.

### Backend Only

```bash
air
```

### Frontend Only

```bash
cd web && npm run dev
```

### Build

```bash
make build
```

## Project Structure

```
.
├── cmd/            # CLI commands (Cobra)
├── internal/       # Application internals
│   ├── conf/       # Configuration
│   ├── handler/    # HTTP handlers
│   ├── middleware/ # Gin middleware
│   ├── model/      # Database models
│   ├── op/         # Business operations
│   ├── router/     # Route definitions
│   └── utils/      # Utilities
├── scripts/        # Build and Docker scripts
├── static/         # Static files
├── web/            # Next.js frontend (App Router)
└── main.go         # Entry point
```

## Configuration

Configuration is loaded from `data/config.json`. If not found, a default config will be created automatically.

Environment variables can override config values with prefix `GOBOILERPLATE_` (e.g., `GOBOILERPLATE_SERVER_PORT=3000`).

## Migration Script

To create a new project from this boilerplate:

```bash
./scripts/migrate.sh my-new-project github.com/myorg/my-new-project
```

This will rename all references from `go-boilerplate`/`goboilerplate` to your new project name.
