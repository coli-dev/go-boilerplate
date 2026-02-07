#!/bin/bash

# =============================================================================
# Migration Script: Rename go-boilerplate to a new project
# =============================================================================
#
# Usage:
#   ./scripts/migrate.sh <new-name> <new-module-path> [--git-user <user>]
#
# Examples:
#   ./scripts/migrate.sh my-app github.com/myorg/my-app
#   ./scripts/migrate.sh my-app github.com/myorg/my-app --git-user myorg
#
# This script replaces all boilerplate references:
#   - Go module path: github.com/coli-dev/go-boilerplate → <new-module-path>
#   - Directory/project name: go-boilerplate → <new-name>
#   - App name: goboilerplate/GoBoilerplate → <new-name> variants
#   - Git author: coli-dev → <git-user>
#   - All import paths and text references
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error()   { echo -e "${RED}❌ $1${NC}" >&2; }
log_step()    { echo -e "\n${BLUE}🔧 $1${NC}"; echo "────────────────────────────────────────"; }

# =============================================================================
# Configuration
# =============================================================================

# Current boilerplate values
OLD_MODULE="github.com/coli-dev/go-boilerplate"
OLD_NAME="go-boilerplate"
OLD_APP_LOWER="goboilerplate"
OLD_APP_TITLE="GoBoilerplate"
OLD_APP_UPPER="GOBOILERPLATE"
OLD_GIT_USER="coli-dev"
OLD_REPO_URL="https://github.com/coli-dev/go-boilerplate"

# =============================================================================
# Parse Arguments
# =============================================================================

show_usage() {
    echo "Usage: $0 <new-name> <new-module-path> [--git-user <user>]"
    echo ""
    echo "Arguments:"
    echo "  new-name          New project name (e.g., my-app, my-service)"
    echo "  new-module-path   New Go module path (e.g., github.com/myorg/my-app)"
    echo ""
    echo "Options:"
    echo "  --git-user <user> Git username/org (default: extracted from module path)"
    echo "  --dry-run         Show what would be changed without making changes"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 my-app github.com/myorg/my-app"
    echo "  $0 my-app github.com/myorg/my-app --git-user myorg"
    echo "  $0 my-app github.com/myorg/my-app --dry-run"
}

NEW_NAME=""
NEW_MODULE=""
NEW_GIT_USER=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --git-user)
            NEW_GIT_USER="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            if [ -z "$NEW_NAME" ]; then
                NEW_NAME="$1"
            elif [ -z "$NEW_MODULE" ]; then
                NEW_MODULE="$1"
            else
                log_error "Unknown argument: $1"
                show_usage
                exit 1
            fi
            shift
            ;;
    esac
done

if [ -z "$NEW_NAME" ] || [ -z "$NEW_MODULE" ]; then
    log_error "Missing required arguments"
    show_usage
    exit 1
fi

# Derive values from new name
# my-app → myapp (lowercase, no hyphens)
NEW_APP_LOWER=$(echo "$NEW_NAME" | tr -d '-' | tr '[:upper:]' '[:lower:]')

# my-app → MyApp (PascalCase)
NEW_APP_TITLE=$(echo "$NEW_NAME" | sed -E 's/(^|-)([a-z])/\U\2/g')

# my-app → MYAPP (uppercase)
NEW_APP_UPPER=$(echo "$NEW_APP_LOWER" | tr '[:lower:]' '[:upper:]')

# Extract git user from module path if not provided
if [ -z "$NEW_GIT_USER" ]; then
    # github.com/myorg/my-app → myorg
    NEW_GIT_USER=$(echo "$NEW_MODULE" | cut -d'/' -f2)
fi

NEW_REPO_URL="https://$NEW_MODULE"

# =============================================================================
# Validation
# =============================================================================

log_step "Migration Configuration"

echo "  Project name:     $OLD_NAME → $NEW_NAME"
echo "  Go module:        $OLD_MODULE → $NEW_MODULE"
echo "  App name (lower): $OLD_APP_LOWER → $NEW_APP_LOWER"
echo "  App name (title): $OLD_APP_TITLE → $NEW_APP_TITLE"
echo "  App name (upper): $OLD_APP_UPPER → $NEW_APP_UPPER"
echo "  Git user:         $OLD_GIT_USER → $NEW_GIT_USER"
echo "  Repo URL:         $OLD_REPO_URL → $NEW_REPO_URL"

if [ "$DRY_RUN" = true ]; then
    log_warning "DRY RUN - no changes will be made"
fi

echo ""
read -p "Continue? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Migration cancelled"
    exit 0
fi

# =============================================================================
# Helper Functions
# =============================================================================

# Replace text in a file (cross-platform)
replace_in_file() {
    local file="$1"
    local old="$2"
    local new="$3"

    if [ "$DRY_RUN" = true ]; then
        if grep -q "$old" "$file" 2>/dev/null; then
            echo "  Would replace '$old' → '$new' in $file"
        fi
        return
    fi

    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|${old}|${new}|g" "$file"
    else
        sed -i "s|${old}|${new}|g" "$file"
    fi
}

# Find files to process (exclude .git, node_modules, build artifacts)
find_files() {
    find . -type f \
        -not -path './.git/*' \
        -not -path '*/node_modules/*' \
        -not -path '*/dist/*' \
        -not -path '*/.next/*' \
        -not -path '*/build/*' \
        -not -path '*/tmp/*' \
        -not -path '*/data/*' \
        -not -path '*/bun.lock' \
        -not -path '*/go.sum' \
        -not -name '*.lock' \
        -not -name '*.png' \
        -not -name '*.jpg' \
        -not -name '*.ico' \
        -not -name '*.woff*' \
        -not -name '*.ttf' \
        -not -name '*.eot' \
        -not -name '*.svg'
}

# =============================================================================
# Migration Steps
# =============================================================================

log_step "Step 1: Replacing Go module path"

for file in $(find_files); do
    replace_in_file "$file" "$OLD_MODULE" "$NEW_MODULE"
done
log_success "Replaced Go module path"

log_step "Step 2: Replacing app name references"

for file in $(find_files); do
    # Order matters: replace longer/more specific strings first
    replace_in_file "$file" "$OLD_REPO_URL" "$NEW_REPO_URL"
    replace_in_file "$file" "$OLD_APP_UPPER" "$NEW_APP_UPPER"
    replace_in_file "$file" "$OLD_APP_TITLE" "$NEW_APP_TITLE"
    replace_in_file "$file" "$OLD_APP_LOWER" "$NEW_APP_LOWER"
done
log_success "Replaced app name references"

log_step "Step 3: Replacing git user"

for file in $(find_files); do
    replace_in_file "$file" "$OLD_GIT_USER" "$NEW_GIT_USER"
done
log_success "Replaced git user references"

log_step "Step 4: Replacing project name in text"

for file in $(find_files); do
    replace_in_file "$file" "$OLD_NAME" "$NEW_NAME"
done
log_success "Replaced project name references"

log_step "Step 5: Updating go.sum"

if [ "$DRY_RUN" = false ]; then
    if command -v go >/dev/null 2>&1; then
        log_info "Running go mod tidy..."
        go mod tidy 2>/dev/null || log_warning "go mod tidy failed (you may need to run it manually)"
    else
        log_warning "Go not found, skipping go mod tidy"
    fi
fi
log_success "Go modules updated"

log_step "Step 6: Reinstalling web dependencies"

if [ "$DRY_RUN" = false ]; then
    if [ -d "web" ]; then
        cd web
        if command -v bun >/dev/null 2>&1; then
            bun install --quiet 2>/dev/null || log_warning "bun install failed"
        elif command -v npm >/dev/null 2>&1; then
            npm install --quiet 2>/dev/null || log_warning "npm install failed"
        fi
        cd ..
    fi
fi
log_success "Web dependencies updated"

# =============================================================================
# Summary
# =============================================================================

log_step "Migration Complete! 🎉"

echo ""
echo "Your project has been migrated from '$OLD_NAME' to '$NEW_NAME'."
echo ""
echo "Next steps:"
echo "  1. Review the changes: git diff"
echo "  2. Build and test:     make build"
echo "  3. Run dev server:     make dev"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo ""
    log_warning "This was a dry run. No files were modified."
fi
