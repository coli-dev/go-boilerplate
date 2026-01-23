# Go Boilerplate

A Go web service boilerplate with Gin, Cobra CLI, and GORM.

## Requirements

- Go 1.24+
- [Air](https://github.com/cosmtrek/air) (for hot reload during development)

## Development

### Install Air

```bash
go install github.com/cosmtrek/air@latest
```

### Run with Hot Reload

```bash
air
```

The server will start at `http://127.0.0.1:8080` and automatically reload when you modify Go files.

### Run without Hot Reload

```bash
go run . start
```

### Build

```bash
./scripts/build.sh
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
