// Playwright configuration for Beer Game E2E tests
const { defineConfig, devices } = require('@playwright/test');

module.exports = defineConfig({
  testDir: './',
  fullyParallel: false, // Run tests sequentially to avoid conflicts
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: 1, // One worker to avoid race conditions
  reporter: [
    ['html'],
    ['list'],
    ['json', { outputFile: 'test-results.json' }]
  ],

  use: {
    baseURL: 'https://demonstrator.valuechainhackers.xyz',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    actionTimeout: 15000,
    navigationTimeout: 30000,
  },

  projects: [
    {
      name: 'chromium',
      use: {
        ...devices['Desktop Chrome'],
        // Ignore HTTPS errors for testing
        ignoreHTTPSErrors: true,
      },
    },

    // Uncomment to test on other browsers
    // {
    //   name: 'firefox',
    //   use: {
    //     ...devices['Desktop Firefox'],
    //     ignoreHTTPSErrors: true,
    //   },
    // },

    // {
    //   name: 'webkit',
    //   use: {
    //     ...devices['Desktop Safari'],
    //     ignoreHTTPSErrors: true,
    //   },
    // },
  ],

  timeout: 300000, // 5 minutes per test (for long gameplay tests)
});
