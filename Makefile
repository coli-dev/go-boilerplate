.PHONY: dev build

dev:
	@echo "Starting development servers..."
	@echo "Frontend: http://localhost:3000"
	@echo "Backend:  http://localhost:8080"
	@trap 'kill 0' SIGINT; \
	(cd web && npm run dev) & \
	air

build:
	@cd web && npm run build
	@./scripts/build.sh
