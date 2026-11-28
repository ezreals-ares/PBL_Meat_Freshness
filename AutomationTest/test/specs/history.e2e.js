const { expect } = require('@wdio/globals');
const HomePage = require('../pageobjects/HomePage');
const HistoryPage = require('../pageobjects/HistoryPage');

describe('History Screen (Riwayat) - MeatFresh AI', () => {
  it('harus menampilkan header dan 4 filter status (SEMUA, SEGAR, SETENGAH SEGAR, BUSUK)', async () => {
    await HomePage.waitForScreenLoaded();
    await HomePage.openRiwayat();

    await HistoryPage.waitForScreenLoaded();
    await expect(HistoryPage.headerTitle).toBeDisplayed();
    await expect(HistoryPage.sampleCountText).toBeDisplayed();
    await expect(HistoryPage.exportButton).toBeDisplayed();

    await expect(HistoryPage.filterAll).toBeDisplayed();
    await expect(HistoryPage.filterFresh).toBeDisplayed();
    await expect(HistoryPage.filterHalfFresh).toBeDisplayed();

    // Filter BUSUK bisa berada di luar viewport kanan; geser ke kanan jika belum terlihat
    if (!(await HistoryPage.filterSpoiled.isExisting())) {
      await HistoryPage.scrollFiltersToEnd();
    }
    await expect(HistoryPage.filterSpoiled).toBeDisplayed();

    // Uji klik filter status lalu kembali ke SEMUA
    await HistoryPage.waitAndClick(HistoryPage.filterFresh);
    if (await HistoryPage.emptyStateTitle.isExisting()) {
      await HistoryPage.tapResetFilter();
      await expect(HistoryPage.filterAll).toBeDisplayed();
    } else {
      await HistoryPage.waitAndClick(HistoryPage.filterAll);
    }

    await expect(HistoryPage.headerTitle).toBeDisplayed();
  });
});
