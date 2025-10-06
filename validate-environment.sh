#!/usr/bin/env bash
# Environment Validation Script
# Validates that all prerequisites are met before deployment

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
error() { echo -e "${RED}✗${NC} $*" >&2; }
warn() { echo -e "${YELLOW}⚠${NC} $*"; }

validation_errors=0
validation_warnings=0

check_failed() {
    ((validation_errors++))
    error "$1"
}

check_warning() {
    ((validation_warnings++))
    warn "$1"
}

check_passed() {
    success "$1"
}

echo "============================================"
echo "   Environment Validation"
echo "============================================"
echo ""

# Check 1: Docker
log "Checking Docker installation..."
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | tr -d ',')
    check_passed "Docker is installed (version $DOCKER_VERSION)"

    # Check if Docker daemon is running
    if docker ps &> /dev/null; then
        check_passed "Docker daemon is running"
    else
        check_failed "Docker is installed but daemon is not running"
    fi
else
    check_failed "Docker is not installed"
fi

# Check 2: Docker database container
log "Checking database container..."
if docker ps --format '{{.Names}}' | grep -q '^database$'; then
    check_passed "Database container is running"

    # Get container IP
    DB_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' database 2>/dev/null || echo "")
    if [[ -n "$DB_IP" ]]; then
        check_passed "Database container IP: $DB_IP"
    else
        check_warning "Could not determine database container IP"
    fi
else
    check_failed "Database container 'database' is not running"
fi

# Check 3: .NET Core
log "Checking .NET Core installation..."
if command -v dotnet &> /dev/null; then
    DOTNET_VERSION=$(dotnet --version)
    check_passed ".NET Core is installed (version $DOTNET_VERSION)"

    # Check for .NET Core 3.1 specifically
    if dotnet --list-runtimes | grep -q "Microsoft.AspNetCore.App 3.1"; then
        check_passed ".NET Core 3.1 runtime is installed"
    else
        check_failed ".NET Core 3.1 runtime is NOT installed"
    fi
else
    check_failed ".NET Core is not installed"
fi

# Check 4: Published applications
log "Checking published application files..."
REPO_DIR="/root/blockchain-demonstrator-serious-game"

if [[ -f "$REPO_DIR/publish/api/BlockchainDemonstratorApi.dll" ]]; then
    check_passed "API application is published"
else
    check_failed "API application is NOT published at $REPO_DIR/publish/api/"
fi

if [[ -f "$REPO_DIR/publish/webapp/BlockchainDemonstratorWebApp.dll" ]]; then
    check_passed "WebApp application is published"
else
    check_failed "WebApp application is NOT published at $REPO_DIR/publish/webapp/"
fi

# Check 5: Port availability
log "Checking port availability..."
for port in 80 8080 5000 5002 1433; do
    if netstat -tuln 2>/dev/null | grep -q ":$port "; then
        if [[ $port == 1433 ]]; then
            # Port 1433 should be used by database container
            check_passed "Port $port is in use (expected for database)"
        elif [[ $port == 80 || $port == 8080 ]]; then
            # Ports 80/8080 should be used by nginx
            check_passed "Port $port is in use (expected for nginx)"
        else
            check_warning "Port $port is in use (may need to stop existing processes)"
        fi
    else
        if [[ $port == 1433 ]]; then
            check_failed "Port $port is NOT in use (database may not be running)"
        elif [[ $port == 80 || $port == 8080 ]]; then
            check_failed "Port $port is NOT in use (nginx may not be running)"
        else
            check_passed "Port $port is available"
        fi
    fi
done

# Check 6: Nginx
log "Checking nginx..."
if command -v nginx &> /dev/null; then
    check_passed "Nginx is installed"

    if systemctl is-active --quiet nginx; then
        check_passed "Nginx is running"

        # Check nginx config
        if nginx -t &> /dev/null; then
            check_passed "Nginx configuration is valid"
        else
            check_warning "Nginx configuration has issues"
        fi
    else
        check_failed "Nginx is installed but not running"
    fi
else
    check_failed "Nginx is not installed"
fi

# Check 7: Nginx configuration file
log "Checking nginx blockchain-demo configuration..."
if [[ -f "/etc/nginx/sites-available/blockchain-demo.conf" ]]; then
    check_passed "Nginx blockchain-demo.conf exists"

    if [[ -L "/etc/nginx/sites-enabled/blockchain-demo.conf" ]]; then
        check_passed "Nginx blockchain-demo.conf is enabled"
    else
        check_warning "Nginx blockchain-demo.conf exists but is not enabled"
    fi
else
    check_warning "Nginx blockchain-demo.conf does not exist"
fi

# Check 8: Database connection string
log "Checking database configuration..."
APPSETTINGS="$REPO_DIR/BlockchainDemonstratorApi/appsettings.json"
if [[ -f "$APPSETTINGS" ]]; then
    if grep -q "BeerGameContext" "$APPSETTINGS"; then
        check_passed "Database connection string found in appsettings.json"
    else
        check_warning "Database connection string may be missing"
    fi
else
    check_warning "appsettings.json not found"
fi

# Check 9: Disk space
log "Checking disk space..."
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
if [[ $DISK_USAGE -lt 90 ]]; then
    check_passed "Disk space is adequate ($DISK_USAGE% used)"
else
    check_warning "Disk space is running low ($DISK_USAGE% used)"
fi

# Check 10: Memory
log "Checking available memory..."
MEM_AVAILABLE=$(free -m | awk 'NR==2 {print $7}')
if [[ $MEM_AVAILABLE -gt 512 ]]; then
    check_passed "Available memory is adequate (${MEM_AVAILABLE}MB available)"
else
    check_warning "Low available memory (${MEM_AVAILABLE}MB available)"
fi

# Summary
echo ""
echo "============================================"
echo "           Validation Summary"
echo "============================================"
echo -e "Errors:   ${RED}$validation_errors${NC}"
echo -e "Warnings: ${YELLOW}$validation_warnings${NC}"
echo ""

if [[ $validation_errors -eq 0 ]]; then
    if [[ $validation_warnings -eq 0 ]]; then
        echo -e "${GREEN}✓ Environment is READY for deployment!${NC}"
        exit 0
    else
        echo -e "${YELLOW}⚠ Environment is ready with warnings${NC}"
        echo -e "${YELLOW}Review warnings above before proceeding${NC}"
        exit 0
    fi
else
    echo -e "${RED}✗ Environment has critical issues that must be fixed${NC}"
    echo -e "${RED}Fix errors above before deploying${NC}"
    exit 1
fi
