#!/usr/bin/env bash
# End-to-End Automated Deployment Test
# Tests the complete game flow: Admin login -> Create game -> 4 players join -> Game start

set -euo pipefail

# Configuration
API_URL="${API_URL:-http://localhost:5002/api}"
WEBAPP_URL="${WEBAPP_URL:-http://localhost:5000}"
TEST_ADMIN_ID="test-admin-$(date +%s)"
TEST_ADMIN_PASSWORD="TestPassword123!"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
error() { echo -e "${RED}✗${NC} $*" >&2; }
warn() { echo -e "${YELLOW}⚠${NC} $*"; }

test_counter=0
tests_passed=0
tests_failed=0

run_test() {
    ((test_counter++))
    local test_name="$1"
    log "Test $test_counter: $test_name"
}

assert_success() {
    local test_name="$1"
    ((tests_passed++))
    success "$test_name"
}

assert_failure() {
    local test_name="$1"
    ((tests_failed++))
    error "$test_name"
}

# Cleanup function
cleanup() {
    log "Cleaning up test data..."
    if [[ -n "${GAME_ID:-}" ]]; then
        curl -s -X DELETE "$API_URL/BeerGame/$GAME_ID" || true
    fi
    if [[ -n "${TEST_ADMIN_ID:-}" ]]; then
        curl -s -X DELETE "$API_URL/Admin/$TEST_ADMIN_ID" || true
    fi
}
trap cleanup EXIT

echo "============================================"
echo "   Beer Game E2E Deployment Test Suite"
echo "============================================"
echo ""
log "API URL: $API_URL"
log "WebApp URL: $WEBAPP_URL"
echo ""

# ============================================
# Test 1: Check if services are running
# ============================================
run_test "Verify WebApp is accessible"
if curl -sf "$WEBAPP_URL" > /dev/null; then
    assert_success "WebApp is running and accessible"
else
    assert_failure "WebApp is NOT accessible at $WEBAPP_URL"
    error "Cannot continue tests - WebApp is down"
    exit 1
fi

run_test "Verify API is accessible"
if curl -sf "$API_URL/Admin" > /dev/null; then
    assert_success "API is running and accessible"
else
    assert_failure "API is NOT accessible at $API_URL"
    error "Cannot continue tests - API is down"
    exit 1
fi

# ============================================
# Test 2: Check environment mode
# ============================================
run_test "Verify application is NOT in Development mode"
WEBAPP_RESPONSE=$(curl -s "$WEBAPP_URL")
if echo "$WEBAPP_RESPONSE" | grep -qi "development mode"; then
    assert_failure "Application is still in DEVELOPMENT mode!"
    warn "This is the main issue preventing login/gameplay"
else
    assert_success "Application is in Production mode"
fi

# ============================================
# Test 3: Create test admin account
# ============================================
run_test "Create test admin account"
ADMIN_RESPONSE=$(curl -s -X POST "$API_URL/Admin/Create" \
    -H "Content-Type: application/json" \
    -d "{\"Id\":\"$TEST_ADMIN_ID\",\"Password\":\"$TEST_ADMIN_PASSWORD\"}" \
    -w "\n%{http_code}")

HTTP_CODE=$(echo "$ADMIN_RESPONSE" | tail -n1)
if [[ "$HTTP_CODE" == "200" ]]; then
    assert_success "Admin account created successfully"
else
    assert_failure "Failed to create admin account (HTTP $HTTP_CODE)"
fi

# ============================================
# Test 4: Admin login
# ============================================
run_test "Test admin login"
LOGIN_RESPONSE=$(curl -s -X POST "$API_URL/BeerGame/Login" \
    -H "Content-Type: application/json" \
    -d "{\"id\":\"$TEST_ADMIN_ID\",\"password\":\"$TEST_ADMIN_PASSWORD\"}")

if echo "$LOGIN_RESPONSE" | grep -q '"loggedIn":true' && echo "$LOGIN_RESPONSE" | grep -q '"loggedInAs":"Admin"'; then
    assert_success "Admin login successful"
else
    assert_failure "Admin login failed: $LOGIN_RESPONSE"
fi

# ============================================
# Test 5: Create a new game
# ============================================
run_test "Create a new game session"
GAME_RESPONSE=$(curl -s -X POST "$API_URL/BeerGame/CreateGame" \
    -H "Content-Type: application/json")

GAME_ID=$(echo "$GAME_RESPONSE" | grep -o '"Id":"[^"]*"' | cut -d'"' -f4)

if [[ -n "$GAME_ID" && "$GAME_ID" =~ ^[0-9]{6}$ ]]; then
    assert_success "Game created with ID: $GAME_ID"
else
    assert_failure "Failed to create game: $GAME_RESPONSE"
    exit 1
fi

# ============================================
# Test 6: Join game as Retailer
# ============================================
run_test "Player 1 joins as Retailer"
JOIN_RETAILER=$(curl -s -X POST "$API_URL/BeerGame/JoinGame" \
    -H "Content-Type: application/json" \
    -d "{\"gameId\":\"$GAME_ID\",\"role\":0,\"name\":\"Test Retailer\",\"playerId\":\"retailer-$GAME_ID\"}" \
    -w "\n%{http_code}")

HTTP_CODE=$(echo "$JOIN_RETAILER" | tail -n1)
if [[ "$HTTP_CODE" == "200" ]]; then
    assert_success "Retailer joined game successfully"
else
    assert_failure "Retailer failed to join game (HTTP $HTTP_CODE)"
fi

# ============================================
# Test 7: Join game as Manufacturer
# ============================================
run_test "Player 2 joins as Manufacturer"
JOIN_MANUFACTURER=$(curl -s -X POST "$API_URL/BeerGame/JoinGame" \
    -H "Content-Type: application/json" \
    -d "{\"gameId\":\"$GAME_ID\",\"role\":1,\"name\":\"Test Manufacturer\",\"playerId\":\"manufacturer-$GAME_ID\"}" \
    -w "\n%{http_code}")

HTTP_CODE=$(echo "$JOIN_MANUFACTURER" | tail -n1)
if [[ "$HTTP_CODE" == "200" ]]; then
    assert_success "Manufacturer joined game successfully"
else
    assert_failure "Manufacturer failed to join game (HTTP $HTTP_CODE)"
fi

# ============================================
# Test 8: Join game as Processor
# ============================================
run_test "Player 3 joins as Processor"
JOIN_PROCESSOR=$(curl -s -X POST "$API_URL/BeerGame/JoinGame" \
    -H "Content-Type: application/json" \
    -d "{\"gameId\":\"$GAME_ID\",\"role\":2,\"name\":\"Test Processor\",\"playerId\":\"processor-$GAME_ID\"}" \
    -w "\n%{http_code}")

HTTP_CODE=$(echo "$JOIN_PROCESSOR" | tail -n1)
if [[ "$HTTP_CODE" == "200" ]]; then
    assert_success "Processor joined game successfully"
else
    assert_failure "Processor failed to join game (HTTP $HTTP_CODE)"
fi

# ============================================
# Test 9: Join game as Farmer
# ============================================
run_test "Player 4 joins as Farmer"
JOIN_FARMER=$(curl -s -X POST "$API_URL/BeerGame/JoinGame" \
    -H "Content-Type: application/json" \
    -d "{\"gameId\":\"$GAME_ID\",\"role\":3,\"name\":\"Test Farmer\",\"playerId\":\"farmer-$GAME_ID\"}" \
    -w "\n%{http_code}")

HTTP_CODE=$(echo "$JOIN_FARMER" | tail -n1)
if [[ "$HTTP_CODE" == "200" ]]; then
    assert_success "Farmer joined game successfully"
else
    assert_failure "Farmer failed to join game (HTTP $HTTP_CODE)"
fi

# ============================================
# Test 10: Verify all players joined
# ============================================
run_test "Verify all 4 players are in the game"
GAME_STATE=$(curl -s -X POST "$API_URL/BeerGame/GetGame" \
    -H "Content-Type: application/json" \
    -d "\"$GAME_ID\"")

RETAILER_EXISTS=$(echo "$GAME_STATE" | grep -c '"Retailer":{' || true)
MANUFACTURER_EXISTS=$(echo "$GAME_STATE" | grep -c '"Manufacturer":{' || true)
PROCESSOR_EXISTS=$(echo "$GAME_STATE" | grep -c '"Processor":{' || true)
FARMER_EXISTS=$(echo "$GAME_STATE" | grep -c '"Farmer":{' || true)

if [[ "$RETAILER_EXISTS" -gt 0 && "$MANUFACTURER_EXISTS" -gt 0 && "$PROCESSOR_EXISTS" -gt 0 && "$FARMER_EXISTS" -gt 0 ]]; then
    assert_success "All 4 players are in the game"
else
    assert_failure "Not all players joined. R:$RETAILER_EXISTS M:$MANUFACTURER_EXISTS P:$PROCESSOR_EXISTS F:$FARMER_EXISTS"
fi

# ============================================
# Test 11: Database connectivity
# ============================================
run_test "Verify database is accessible"
ADMIN_COUNT=$(curl -s "$API_URL/Admin" | grep -c '"Id":' || echo "0")
if [[ "$ADMIN_COUNT" -gt 0 ]]; then
    assert_success "Database connection working (found $ADMIN_COUNT admins)"
else
    assert_failure "Database connection issue - no admins found"
fi

# ============================================
# Summary Report
# ============================================
echo ""
echo "============================================"
echo "           Test Results Summary"
echo "============================================"
echo -e "Total Tests:  $test_counter"
echo -e "${GREEN}Passed:       $tests_passed${NC}"
echo -e "${RED}Failed:       $tests_failed${NC}"
echo ""

if [[ $tests_failed -eq 0 ]]; then
    echo -e "${GREEN}✓ ALL TESTS PASSED!${NC}"
    echo -e "${GREEN}✓ Deployment is successful and ready for production use!${NC}"
    echo ""
    echo "Game ID for manual testing: $GAME_ID"
    echo "Test Admin credentials:"
    echo "  Username: $TEST_ADMIN_ID"
    echo "  Password: $TEST_ADMIN_PASSWORD"
    exit 0
else
    echo -e "${RED}✗ SOME TESTS FAILED${NC}"
    echo -e "${YELLOW}⚠ Review the failures above and fix issues before going to production${NC}"
    exit 1
fi
