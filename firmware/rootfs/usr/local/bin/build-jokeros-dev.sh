#!/bin/bash
# JokerOS Development Environment Builder
# Builds a complete development environment for JokerOS/JesterOS
# "By quill and candlelight, we craft the development realm!"

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
VERSION="${VERSION:-1.0-dev}"

log() {
    echo -e "${GREEN}[JOKEROS-BUILD]${NC} $1"
}

info() {
    echo -e "${BLUE}[JOKEROS-BUILD]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[JOKEROS-BUILD]${NC} $1"
}

error() {
    echo -e "${RED}[JOKEROS-BUILD]${NC} $1" >&2
}

show_banner() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════════╗"
    echo "║                    JOKEROS DEVELOPMENT BUILDER                      ║"
    echo "║                                                                      ║"
    echo "║      🏰 Building authentic development environment from 2009        ║"
    echo "║         \"Crafting digital destiny with medieval precision!\"         ║"
    echo "╚══════════════════════════════════════════════════════════════════════╝"
    echo ""
}

check_requirements() {
    log "Checking build requirements..."
    
    # Check for Docker
    if ! command -v docker >/dev/null 2>&1; then
        error "Docker is required but not installed"
        exit 1
    fi
    
    # Check for Lenny rootfs
    if [ ! -f "$PROJECT_ROOT/lenny-rootfs.tar.gz" ]; then
        error "Lenny rootfs not found: $PROJECT_ROOT/lenny-rootfs.tar.gz"
        echo ""
        echo "To create the rootfs:"
        echo "  sudo ./scripts/build-lenny-rootfs.sh"
        exit 1
    fi
    
    local size=$(du -h "$PROJECT_ROOT/lenny-rootfs.tar.gz" | cut -f1)
    log "✓ Found Lenny rootfs: $size"
}

build_development_image() {
    log "Building JokerOS development environment..."
    
    cd "$PROJECT_ROOT"
    
    # Build the development image
    docker build \
        --progress=plain \
        --no-cache \
        -f build/docker/jokeros-development.dockerfile \
        --build-arg BUILD_DATE="$BUILD_DATE" \
        --build-arg VERSION="$VERSION" \
        -t jokeros:dev \
        -t jokeros:latest \
        -t jokeros:"$VERSION" \
        . || {
        error "Failed to build JokerOS development image"
        exit 1
    }
    
    log "✓ JokerOS development image built successfully"
}

test_development_environment() {
    log "Testing JokerOS development environment..."
    
    info "Testing basic functionality..."
    docker run --rm jokeros:dev bash -c '
        echo "=== Environment Test ==="
        echo "OS: $(cat /etc/issue | head -1)"
        echo "Debian: $(cat /etc/debian_version)"
        echo "Architecture: $(uname -m)"
        echo ""
        echo "=== Development Tools ==="
        echo "Git: $(git --version)"
        echo "Vim: $(vim --version | head -1)"
        echo "Make: $(make --version | head -1)"
        echo ""
        echo "=== JokerOS Structure ==="
        ls -la /jokeros/
        echo ""
        echo "✅ Development environment functional!"
    '
    
    info "Testing JokerOS initialization..."
    docker run --rm jokeros:dev bash -c '
        source /root/.bashrc
        jokeros-init
        ls -la /jokeros/
        echo ""
        echo "✅ JokerOS initialization works!"
    '
    
    log "✓ Development environment tests passed"
}

show_usage_info() {
    log "JokerOS development environment ready!"
    
    echo ""
    echo -e "${BLUE}Usage Examples:${NC}"
    echo ""
    echo "🔧 Start development session:"
    echo "  docker run -it --rm -v \$(pwd):/workspace jokeros:dev"
    echo ""
    echo "🏗️ Build with project mounted:"
    echo "  docker run -it --rm -v \$(pwd):/workspace -w /workspace jokeros:dev"
    echo ""
    echo "📝 Quick development shell:"
    echo "  docker run -it --rm jokeros:dev"
    echo ""
    echo "🎭 Medieval inspiration:"
    echo "  docker run --rm jokeros:dev medieval"
    echo ""
    echo -e "${BLUE}Development Commands (inside container):${NC}"
    echo "  jokeros-help      - Show all development commands"
    echo "  jokeros-init      - Initialize project structure" 
    echo "  build-jokeros     - Build the project"
    echo "  test-jokeros      - Run tests"
    echo "  deploy-nook       - Deploy to hardware"
    echo ""
    echo -e "${BLUE}Image Information:${NC}"
    docker images jokeros:dev --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
    echo ""
}

show_github_info() {
    log "GitHub publishing information..."
    
    echo ""
    echo -e "${BLUE}GitHub Container Registry:${NC}"
    echo ""
    echo "🏷️  Tag for publishing:"
    echo "  docker tag jokeros:dev ghcr.io/bogdanscarwash/jokeros-dev:latest"
    echo "  docker tag jokeros:dev ghcr.io/bogdanscarwash/jokeros-dev:$VERSION"
    echo ""
    echo "📤 Push to GitHub:"
    echo "  docker push ghcr.io/bogdanscarwash/jokeros-dev:latest"
    echo "  docker push ghcr.io/bogdanscarwash/jokeros-dev:$VERSION"
    echo ""
    echo "📥 Pull from GitHub:"
    echo "  docker pull ghcr.io/bogdanscarwash/jokeros-dev:latest"
    echo ""
    echo -e "${BLUE}GitHub Actions Integration:${NC}"
    echo "  See: .github/workflows/build-jokeros-dev.yml"
    echo ""
}

cleanup() {
    log "Cleaning up build resources..."
    docker system prune -f --filter label=stage=jokeros-build 2>/dev/null || true
}

main() {
    local build_only=false
    local test_only=false
    local show_github=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --build-only)
                build_only=true
                shift
                ;;
            --test-only)
                test_only=true
                shift
                ;;
            --github-info)
                show_github=true
                shift
                ;;
            --version)
                VERSION="$2"
                shift 2
                ;;
            --help)
                cat << EOF
JokerOS Development Environment Builder

Usage: $0 [OPTIONS]

Options:
  --build-only     Build image without testing
  --test-only      Test existing image
  --github-info    Show GitHub publishing information
  --version VER    Set version tag (default: 1.0-dev)
  --help           Show this help

Examples:
  $0                           # Build and test
  $0 --build-only              # Just build
  $0 --version 1.1-dev         # Build with version tag
  $0 --github-info             # Show publishing info
EOF
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    show_banner
    
    if [ "$test_only" != true ]; then
        check_requirements
        build_development_image
    fi
    
    if [ "$build_only" != true ]; then
        test_development_environment
    fi
    
    if [ "$show_github" = true ]; then
        show_github_info
    else
        show_usage_info
    fi
    
    cleanup
    
    echo ""
    echo -e "${GREEN}🏰 JokerOS development environment ready for medieval coding!${NC}"
    echo -e "${YELLOW}\"By quill and candlelight, the digital realm awaits!\"${NC}"
    echo ""
}

main "$@"