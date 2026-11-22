const { expect } = require('@wdio/globals');
const HomePage = require('../pageobjects/HomePage');

describe('Home Screen (Beranda) - MeatFresh AI', () => {
  it('harus menampilkan elemen utama beranda dengan lengkap', async () => {
    await HomePage.waitForScreenLoaded();

    await expect(HomePage.appTitle).toBeDisplayed();
    await expect(HomePage.heroBanner).toBeDisplayed();
    await expect(HomePage.startCheckButton).toBeDisplayed();
    await expect(HomePage.quickHistoryButton).toBeDisplayed();
    await expect(HomePage.quickUploadButton).toBeDisplayed();

    // Scroll ke bawah jika kartu panduan & disclaimer berada di luar viewport awal
    if (!(await HomePage.safetyDisclaimer.isExisting())) {
      await HomePage.scrollDown();
    }
    await expect(HomePage.storageRecommendation).toBeDisplayed();
    await expect(HomePage.safetyDisclaimer).toBeDisplayed();
  });
});
