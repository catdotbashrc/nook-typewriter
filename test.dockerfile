FROM ubuntu:20.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install basic tools needed for JesterOS testing
RUN apt-get update && apt-get install -y \
    bash \
    coreutils \
    procps \
    psmisc \
    vim \
    less \
    && rm -rf /var/lib/apt/lists/*

# Create the runtime directory structure
RUN mkdir -p /runtime

# Copy the entire runtime directory
COPY runtime/ /runtime/

# Create system directories that JesterOS expects
RUN mkdir -p /var/jesteros \
    /var/jesteros/typewriter \
    /var/jesteros/health \
    /var/jesteros/services \
    /var/run/jesteros \
    /var/log/jesteros \
    /var/lib/jester \
    /etc/jesteros/services \
    /root/manuscripts \
    /root/notes \
    /root/drafts \
    /root/scrolls

# Copy service configurations to system location
COPY runtime/configs/services/* /etc/jesteros/services/

# Create symlinks for service executables in /usr/local/bin
RUN ln -sf /runtime/2-application/jesteros/jester-daemon.sh /usr/local/bin/jester-daemon.sh && \
    ln -sf /runtime/2-application/jesteros/jesteros-tracker.sh /usr/local/bin/jesteros-tracker.sh && \
    ln -sf /runtime/2-application/jesteros/health-check.sh /usr/local/bin/health-check.sh && \
    ln -sf /runtime/2-application/jesteros/manager.sh /usr/local/bin/jesteros-manager.sh

# Make all scripts executable
RUN find /runtime -name "*.sh" -type f -exec chmod +x {} \;

# Set environment variables for JesterOS
ENV RUNTIME_BASE=/runtime
ENV JESTEROS_BASE=/var/jesteros
ENV COMMON_PATH=/runtime/3-system/common/common.sh

# Create a test script for comprehensive JesterOS testing
RUN cat > /test-jesteros.sh << 'EOF'
#!/bin/bash
set -euo pipefail

echo "🎭 JesterOS Userspace Service System Test"
echo "=========================================="
echo ""

# Test 1: Directory Structure
echo "📁 Test 1: Checking directory structure..."
dirs=("/var/jesteros" "/var/jesteros/typewriter" "/var/jesteros/health" 
      "/var/run/jesteros" "/var/log/jesteros" "/var/lib/jester"
      "/etc/jesteros/services" "/root/manuscripts")

all_dirs_ok=true
for dir in "${dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo "  ✓ $dir exists"
    else
        echo "  ✗ $dir missing"
        all_dirs_ok=false
    fi
done

if $all_dirs_ok; then
    echo "✅ Directory structure: PASS"
else
    echo "❌ Directory structure: FAIL"
fi
echo ""

# Test 2: Service Configurations
echo "📋 Test 2: Service configurations..."
configs=("jester.conf" "tracker.conf" "health.conf")
all_configs_ok=true

for config in "${configs[@]}"; do
    config_path="/etc/jesteros/services/$config"
    if [ -f "$config_path" ]; then
        echo -n "  ✓ $config exists... "
        # Test if config can be sourced
        if (. "$config_path" && [ -n "$SERVICE_NAME" ]); then
            echo "valid"
        else
            echo "invalid syntax"
            all_configs_ok=false
        fi
    else
        echo "  ✗ $config missing"
        all_configs_ok=false
    fi
done

if $all_configs_ok; then
    echo "✅ Service configurations: PASS"
else
    echo "❌ Service configurations: FAIL"
fi
echo ""

# Test 3: Service Executables
echo "🔧 Test 3: Service executables..."
services=("jester-daemon.sh" "jesteros-tracker.sh" "health-check.sh" "manager.sh")
all_services_ok=true

for service in "${services[@]}"; do
    service_path="/usr/local/bin/$service"
    runtime_path="/runtime/2-application/jesteros/${service%-daemon}"
    runtime_path="${runtime_path%-s}"
    
    if [ -x "$service_path" ]; then
        echo "  ✓ $service is executable"
    else
        echo "  ✗ $service not executable"
        all_services_ok=false
    fi
done

if $all_services_ok; then
    echo "✅ Service executables: PASS"
else
    echo "❌ Service executables: FAIL"
fi
echo ""

# Test 4: Service Manager Functionality
echo "⚙️ Test 4: Service manager functionality..."
manager="/usr/local/bin/jesteros-manager.sh"

if [ -x "$manager" ]; then
    echo "  Testing service manager initialization..."
    if timeout 30 "$manager" init; then
        echo "  ✓ Service manager initialization: SUCCESS"
        
        echo "  Testing service status check..."
        if "$manager" status all; then
            echo "  ✓ Service status check: SUCCESS"
        else
            echo "  ⚠ Service status check: Some issues (may be normal)"
        fi
        
        echo "✅ Service manager: PASS"
    else
        echo "  ✗ Service manager initialization: FAILED"
        echo "❌ Service manager: FAIL"
    fi
else
    echo "  ✗ Service manager not found or not executable"
    echo "❌ Service manager: FAIL"
fi
echo ""

# Test 5: Individual Service Testing
echo "🧪 Test 5: Individual service testing..."

# Test health check
echo "  Testing health check service..."
if timeout 10 /usr/local/bin/health-check.sh check; then
    if [ -f "/var/jesteros/health/status" ]; then
        echo "  ✓ Health check: Created status file"
        echo "    Health status content:"
        head -n 5 /var/jesteros/health/status | sed 's/^/      /'
    else
        echo "  ⚠ Health check: Ran but no status file created"
    fi
else
    echo "  ✗ Health check: Failed to run"
fi

# Test jester daemon status
echo "  Testing jester daemon..."
if timeout 5 /usr/local/bin/jester-daemon.sh status; then
    echo "  ✓ Jester daemon: Status check successful"
else
    echo "  ⚠ Jester daemon: Status check had issues (expected without full startup)"
fi

# Test tracker status
echo "  Testing tracker service..."
if timeout 5 /usr/local/bin/jesteros-tracker.sh status; then
    echo "  ✓ Tracker service: Status check successful"
else
    echo "  ⚠ Tracker service: Status check had issues (expected without full startup)"
fi

echo ""

# Test 6: Full Service Initialization
echo "🚀 Test 6: Full service initialization..."
init_script="/runtime/init/jesteros-service-init.sh"

if [ -x "$init_script" ]; then
    echo "  Running complete JesterOS initialization..."
    if timeout 60 "$init_script" init; then
        echo "  ✅ Full initialization: SUCCESS"
        
        echo ""
        echo "📊 Final Interface Status:"
        echo "------------------------"
        
        if [ -f "/var/jesteros/jester" ]; then
            echo "🎭 Jester Interface:"
            head -n 8 /var/jesteros/jester | sed 's/^/   /'
            echo ""
        fi
        
        if [ -f "/var/jesteros/typewriter/stats" ]; then
            echo "📜 Typewriter Stats:"
            head -n 10 /var/jesteros/typewriter/stats | sed 's/^/   /'
            echo ""
        fi
        
        if [ -f "/var/jesteros/health/status" ]; then
            echo "🏥 Health Status:"
            head -n 8 /var/jesteros/health/status | sed 's/^/   /'
            echo ""
        fi
        
    else
        echo "  ❌ Full initialization: FAILED"
    fi
else
    echo "  ✗ Initialization script not found: $init_script"
    echo "❌ Full initialization: FAIL"
fi

echo ""
echo "🎯 Test Summary"
echo "==============="
echo "JesterOS userspace service system testing completed."
echo ""
echo "Key interfaces should now be available at:"
echo "  • /var/jesteros/jester (ASCII art and mood)"
echo "  • /var/jesteros/typewriter/stats (writing statistics)"
echo "  • /var/jesteros/health/status (system health)"
echo ""
echo "Service management available via:"
echo "  • /usr/local/bin/jesteros-manager.sh {start|stop|status} [service]"
echo ""
EOF

RUN chmod +x /test-jesteros.sh

# Default command runs the test
CMD ["/test-jesteros.sh"]