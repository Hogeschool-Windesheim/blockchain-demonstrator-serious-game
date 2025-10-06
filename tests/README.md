# Blockchain Demonstrator E2E Tests

Automated end-to-end tests using Playwright to verify the Beer Game application.

## Setup

1. Install dependencies:
```bash
cd tests
npm install
npx playwright install
```

## Running Tests

### Run all tests:
```bash
npm test
```

### Run specific test suites:
```bash
# Test HTTPS login only
npm run test:https

# Test HTTP login only
npm run test:http

# Test 30-round gameplay
npm run test:30rounds

# Test 50-round gameplay
npm run test:50rounds
```

### Run with UI (interactive mode):
```bash
npm run test:ui
```

### Run in headed mode (see browser):
```bash
npm run test:headed
```

### Debug tests:
```bash
npm run test:debug
```

## Test Coverage

The test suite covers:

1. **Login Tests**
   - ✓ Login via HTTPS domain (`https://demonstrator.valuechainhackers.xyz`)
   - ✓ Login via HTTP direct IP (`http://10.0.5.13:5000`)

2. **Game Creation**
   - ✓ Admin can create new game
   - ✓ Game code is generated (6 digits)

3. **Player Join**
   - ✓ 4 players can join game
   - ✓ All roles assigned (Retailer, Manufacturer, Processor, Farmer)

4. **Gameplay Tests**
   - ✓ Play through 30 rounds
   - ✓ Play through 50 rounds
   - ✓ Full validation game with score tracking

## Test Results

After running tests, view the HTML report:
```bash
npm run report
```

## Configuration

Edit `playwright.config.js` to:
- Change browsers (Chrome, Firefox, Safari)
- Adjust timeouts
- Modify screenshot/video settings
- Enable parallel execution

## Troubleshooting

**Tests failing?**
1. Check that the application is running at `https://demonstrator.valuechainhackers.xyz`
2. Verify the API is accessible at `https://api.demonstrator.valuechainhackers.xyz`
3. Check server logs: `journalctl -u beergame-webapp -u beergame-api -f`

**Timeouts?**
- Increase timeout in `playwright.config.js`
- Check network latency
- Verify SignalR connection is working

**Element not found?**
- The selectors may need adjustment if the UI has changed
- Run with `--debug` to inspect elements
