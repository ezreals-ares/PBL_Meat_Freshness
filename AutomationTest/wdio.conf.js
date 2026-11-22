const fs = require('fs');
const path = require('path');

// Pastikan ANDROID_HOME dan platform-tools tersedia di environment untuk Appium/adb
const defaultAndroidSdk = process.env.LOCALAPPDATA
  ? path.join(process.env.LOCALAPPDATA, 'Android', 'Sdk')
  : 'C:\\Users\\Ezreals_\\AppData\\Local\\Android\\sdk';

const resolvedAndroidHome =
  process.env.ANDROID_HOME ||
  process.env.ANDROID_SDK_ROOT ||
  (fs.existsSync(defaultAndroidSdk) ? defaultAndroidSdk : defaultAndroidSdk);

process.env.ANDROID_HOME = resolvedAndroidHome;
process.env.ANDROID_SDK_ROOT = resolvedAndroidHome;

const sdkPaths = [
  path.join(resolvedAndroidHome, 'platform-tools'),
  path.join(resolvedAndroidHome, 'emulator'),
];

for (const sdkPath of sdkPaths) {
  if (fs.existsSync(sdkPath) && !(process.env.PATH || '').includes(sdkPath)) {
    process.env.PATH = `${sdkPath}${path.delimiter}${process.env.PATH || ''}`;
  }
}

const defaultApkPath = path.resolve(
  __dirname,
  '../MobileApps/build/app/outputs/flutter-apk/app-debug.apk'
);
const configuredApkPath = process.env.APP_PATH
  ? path.resolve(process.env.APP_PATH)
  : defaultApkPath;

const androidCapabilities = {
  platformName: 'Android',
  'appium:automationName': 'UiAutomator2',
  'appium:deviceName': process.env.DEVICE_NAME || 'Android Emulator',
  'appium:appPackage': 'com.meatfresh.ai',
  'appium:appActivity': 'com.example.flutter_application_1.MainActivity',
  'appium:autoGrantPermissions': true,
  'appium:noReset': false,
  'appium:newCommandTimeout': 120,
  'appium:uiautomator2ServerReadTimeout': 60000,
  // Matikan waitForIdleTimeout & waitForSelectorTimeout agar animasi loop Flutter tidak memblokir UiAutomator2
  'appium:settings[waitForIdleTimeout]': 0,
  'appium:settings[waitForSelectorTimeout]': 0,
};

if (process.env.UDID) {
  androidCapabilities['appium:udid'] = process.env.UDID;
}

if (fs.existsSync(configuredApkPath)) {
  androidCapabilities['appium:app'] = configuredApkPath;
}

exports.config = {
  runner: 'local',
  specs: ['./test/specs/**/*.e2e.js'],
  exclude: [],
  maxInstances: 1,
  capabilities: [androidCapabilities],
  logLevel: 'info',
  bail: 0,
  waitforTimeout: 10000,
  connectionRetryTimeout: 60000,
  connectionRetryCount: 2,
  services: [
    [
      'appium',
      {
        args: {
          address: '127.0.0.1',
          port: 4723,
        },
        logPath: './logs',
      },
    ],
  ],
  framework: 'mocha',
  reporters: [
    'spec',
    [
      'allure',
      {
        outputDir: 'allure-results',
        disableWebdriverStepsReporting: true,
        disableWebdriverScreenshotsReporting: false,
      },
    ],
  ],
  mochaOpts: {
    ui: 'bdd',
    timeout: 60000,
  },
  afterTest: async function (test, context, { passed }) {
    if (!passed) {
      try {
        const screenshotDir = path.resolve(__dirname, 'screenshots');
        fs.mkdirSync(screenshotDir, { recursive: true });
        const safeTitle = `${test.parent}_${test.title}`
          .replace(/[^a-zA-Z0-9_-]+/g, '_')
          .slice(0, 120);
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
        const filePath = path.join(screenshotDir, `${safeTitle}_${timestamp}.png`);
        await browser.saveScreenshot(filePath);
        await browser.takeScreenshot();
      } catch (_) {
        // Abaikan error screenshot jika session UiAutomator2 sudah terputus
      }
    }
  },
};
