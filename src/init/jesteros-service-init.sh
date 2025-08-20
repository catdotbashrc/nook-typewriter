#!/bin/bash
# JesterOS Service Initialization
# Comprehensive startup script for all JesterOS userspace services
# "By quill and candlelight, we serve the realm of writing!"

# Set TERM if not set (for Docker environments)
export TERM="${TERM:-xterm}"

# Safety settings
set -euo pipefail
trap 'echo "Error in jesteros-service-init.sh at line $LINENO" >&2' ERR

# Source common functions if available
COMMON_PATH="${COMMON_PATH:-/src/3-system/common/common.sh}"
if [[ -f "$COMMON_PATH" ]]; then
    source "$COMMON_PATH"
fi

# Service paths and directories
RUNTIME_BASE="${RUNTIME_BASE:-/runtime}"
SERVICE_MANAGER="$RUNTIME_BASE/2-application/jesteros/manager.sh"
JESTEROS_BASE="/var/jesteros"
SERVICE_CONFIG_BASE="$RUNTIME_BASE/configs/services"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Logging
log() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date '+%H:%M:%S')] WARNING:${NC} $1"
}

error() {
    echo -e "${RED}[$(date '+%H:%M:%S')] ERROR:${NC} $1" >&2
}

# Create all required directories
init_jesteros_directories() {
    log "Creating JesterOS directory structure..."
    
    # Core JesterOS directories
    mkdir -p "$JESTEROS_BASE"
    mkdir -p "$JESTEROS_BASE/typewriter"
    mkdir -p "$JESTEROS_BASE/health"
    mkdir -p "$JESTEROS_BASE/services"
    
    # Service directories
    mkdir -p "/var/run/jesteros"
    mkdir -p "/var/log/jesteros"
    mkdir -p "/var/lib/jester"
    mkdir -p "/etc/jesteros/services"
    
    # Writing directories
    mkdir -p "/root/manuscripts"
    mkdir -p "/root/notes"
    mkdir -p "/root/drafts"
    mkdir -p "/root/scrolls"
    
    log "✓ Directory structure created"
}

# Copy service configurations to system locations
install_service_configs() {
    log "Installing service configurations..."
    
    if [ -d "$SERVICE_CONFIG_BASE" ]; then
        cp -r "$SERVICE_CONFIG_BASE"/* "/etc/jesteros/services/" 2>/dev/null || {
            warn "Could not copy service configs from $SERVICE_CONFIG_BASE"
        }
        log "✓ Service configurations installed"
    else
        warn "Service config directory not found: $SERVICE_CONFIG_BASE"
    fi
}

# Initialize core JesterOS interface files
init_jesteros_interface() {
    log "Initializing JesterOS interface..."
    
    # Create initial jester state
    cat > "$JESTEROS_BASE/jester" << 'EOF'
     ___
    /o o\   JesterOS v1.0
   | > < |  "Awakening the digital court..."  
   |  _  |  
    \___/   Status: INITIALIZING
     | |    Mood: Eager to serve!
    /||\   
   d | |b   *preparing quills and parchments*
EOF
    
    # Initialize typewriter stats
    cat > "$JESTEROS_BASE/typewriter/stats" << 'EOF'
╔════════════════════════════════════╗
║     TYPEWRITER STATISTICS          ║
╚════════════════════════════════════╝

📜 Writing Progress:
   Words Written:    0
   Characters Typed: 0
   
⏰ Session Info:
   Current Session:  0 minutes
   Writing Streak:   0 days
   Last Activity:    Never
   
🎭 Jester's Welcome:
   "Welcome to thy writing sanctuary!"
   "Let the words flow like a gentle stream."

═══════════════════════════════════
   "The quill awaits thy command!"
═══════════════════════════════════
EOF
    
    # Create wisdom file
    echo "The greatest stories begin with a single word." > "$JESTEROS_BASE/wisdom"
    
    # Initialize health status
    mkdir -p "$JESTEROS_BASE/health"
    echo "INITIALIZING" > "$JESTEROS_BASE/health/status"
    
    log "✓ JesterOS interface initialized"
}

# Display startup banner
show_startup_banner() {
    clear
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                        JESTEROS v1.0                         ║
║                                                               ║
║              🎭    Digital Court Awakening    🏰              ║
║                                                               ║
║     "By quill and candlelight, we serve the realm!"          ║
╚═══════════════════════════════════════════════════════════════╝

                           ___
                          /^ ^\   
                         | ◉ ◉ |  
                         |  ‿  |  
                          \___/   
                           | |    
                          /||\   
                         d | |b   
                       *jingle jingle*

══════════════════════════════════════════════════════════════════
EOF
    
    sleep 3
}

# Start individual service with error handling
start_service() {
    local service_name="$1"
    log "Starting $service_name service..."
    
    if [ -f "$SERVICE_MANAGER" ]; then
        if "$SERVICE_MANAGER" start "$service_name"; then
            log "✓ $service_name service started"
            return 0
        else
            error "✗ Failed to start $service_name service"
            return 1
        fi
    else
        error "Service manager not found: $SERVICE_MANAGER"
        return 1
    fi
}

# Start all JesterOS services in proper order
start_all_services() {
    log "Starting JesterOS services in dependency order..."
    
    # Start services in order: jester -> tracker -> health
    local services=("jester" "tracker" "health")
    local failed_services=()
    
    for service in "${services[@]}"; do
        if ! start_service "$service"; then
            failed_services+=("$service")
        fi
        sleep 2  # Brief pause between services
    done
    
    if [ ${#failed_services[@]} -eq 0 ]; then
        log "✓ All JesterOS services started successfully!"
    else
        warn "Some services failed to start: ${failed_services[*]}"
        return 1
    fi
}

# Verify service health
verify_services() {
    log "Verifying service health..."
    
    local all_healthy=true
    
    # Check core interface files exist
    if [ ! -f "$JESTEROS_BASE/jester" ]; then
        error "Jester interface missing"
        all_healthy=false
    fi
    
    if [ ! -f "$JESTEROS_BASE/typewriter/stats" ]; then
        error "Tracker interface missing" 
        all_healthy=false
    fi
    
    if [ ! -f "$JESTEROS_BASE/health/status" ]; then
        error "Health interface missing"
        all_healthy=false
    fi
    
    # Check service manager
    if [ -f "$SERVICE_MANAGER" ]; then
        if "$SERVICE_MANAGER" status all >/dev/null 2>&1; then
            log "✓ Service manager operational"
        else
            warn "Service manager reports issues"
            all_healthy=false
        fi
    else
        error "Service manager missing"
        all_healthy=false
    fi
    
    if $all_healthy; then
        log "✓ All services verified healthy"
        return 0
    else
        error "Service verification failed"
        return 1
    fi
}

# Show completion message
show_completion_message() {
    cat << 'EOF'

╔═══════════════════════════════════════════════════════════════╗
║                    🎭 COURT IS IN SESSION! 🏰                ║
╚═══════════════════════════════════════════════════════════════╝

The digital realm is ready for thy words!

📜 Available Commands:
   • View jester mood:        cat /var/jesteros/jester
   • Check writing stats:     cat /var/jesteros/typewriter/stats  
   • Monitor system health:   cat /var/jesteros/health/status
   • Service management:      /src/2-application/jesteros/manager.sh

🎯 Next Steps:
   1. Start writing with vim /root/manuscripts/my-story.txt
   2. Watch the jester's mood change as you write
   3. Check your progress in the typewriter stats

"May thy words flow like wine and thy stories inspire the realm!"

═══════════════════════════════════════════════════════════════════
EOF
}

# Main initialization sequence
main() {
    log "🎭 JesterOS Service Initialization Starting..."
    
    # Core initialization
    show_startup_banner
    init_jesteros_directories
    install_service_configs
    init_jesteros_interface
    
    # Service startup
    if start_all_services; then
        # Verification
        sleep 5  # Allow services to fully initialize
        if verify_services; then
            show_completion_message
            log "✅ JesterOS initialization completed successfully!"
            return 0
        else
            error "❌ Service verification failed"
            return 1
        fi
    else
        error "❌ Service startup failed"
        return 1
    fi
}

# Handle command line arguments
case "${1:-init}" in
    init|start)
        main
        ;;
    status)
        log "Checking JesterOS service status..."
        if [ -f "$SERVICE_MANAGER" ]; then
            "$SERVICE_MANAGER" status all
        else
            error "Service manager not found"
            exit 1
        fi
        ;;
    stop)
        log "Stopping JesterOS services..."
        if [ -f "$SERVICE_MANAGER" ]; then
            "$SERVICE_MANAGER" stop all
        else
            error "Service manager not found"
            exit 1
        fi
        ;;
    directories)
        # Just create directories (useful for testing)
        init_jesteros_directories
        ;;
    interface)
        # Just initialize interface (useful for testing)
        init_jesteros_interface
        ;;
    *)
        echo "Usage: $0 {init|start|status|stop|directories|interface}"
        echo ""
        echo "Commands:"
        echo "  init        - Complete JesterOS initialization (default)"
        echo "  start       - Same as init"
        echo "  status      - Show service status"
        echo "  stop        - Stop all services"
        echo "  directories - Create directory structure only" 
        echo "  interface   - Initialize interface files only"
        exit 1
        ;;
esac