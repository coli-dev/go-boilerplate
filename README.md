# Go Boilerplate

A Go web service boilerplate with Gin, Cobra CLI, and GORM.

## Requirements

- Go 1.24+
- Node.js 20+
- [Air](https://github.com/cosmtrek/air) (for hot reload during development)

## Quick Start

```bash
go install github.com/cosmtrek/air@latest
cd web && npm install && cd ..
make dev
```

Open http://localhost:5173 - both frontend and backend hot reload on code changes.

## Development

### Full Stack Dev (Recommended)

```bash
make dev
```

Runs both backend (Air) and frontend (Vite) with hot reload. Frontend at `http://localhost:5173` proxies API calls to backend at `http://localhost:8080`.

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
└── main.go         # Entry point
```

## Configuration

Configuration is loaded from `data/config.json`. If not found, a default config will be created automatically.

Environment variables can override config values with prefix `EXAMPLE_` (e.g., `EXAMPLE_SERVER_PORT=3000`).
