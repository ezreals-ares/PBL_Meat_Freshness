const { expect } = require('@wdio/globals');
const HomePage = require('../pageobjects/HomePage');
const CapturePage = require('../pageobjects/CapturePage');

describe('Capture Screen (Pindai) - MeatFresh AI', () => {
  it('harus menampilkan viewfinder, badge target, kartu kamera, dan kartu galeri', async () => {
    await HomePage.waitForScreenLoaded();
    await HomePage.openPindai();

    await CapturePage.waitForScreenLoaded();
    await expect(CapturePage.headerSubtitle).toBeDisplayed();
    await expect(CapturePage.headerTitle).toBeDisplayed();
    await expect(CapturePage.targetBadge).toBeDisplayed();
    await expect(CapturePage.cameraCard).toBeDisplayed();
    await expect(CapturePage.galleryCard).toBeDisplayed();
  });
});
