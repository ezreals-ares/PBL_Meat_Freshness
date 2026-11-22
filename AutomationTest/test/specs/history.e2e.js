const { driver, expect } = require('@wdio/globals');
const HomePage = require('../pageobjects/HomePage');
const HistoryPage = require('../pageobjects/HistoryPage');

describe('History Screen (Riwayat) - MeatFresh AI', () => {
  it('harus menampilkan header, filter chip, kolom pencarian, dan reset filter', async () => {
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

    // Uji input pencarian dan reset filter
    await HistoryPage.search('tidak-ada-hasil-xyz');
    await driver.hideKeyboard().catch(() => {});

    await expect(HistoryPage.emptyStateTitle).toBeDisplayed();
    await expect(HistoryPage.resetFilterButton).toBeDisplayed();

    await HistoryPage.tapResetFilter();
    await expect(HistoryPage.headerTitle).toBeDisplayed();
    await expect(HistoryPage.searchInput).not.toHaveText(
      expect.stringContaining('tidak-ada-hasil-xyz')
    );
  });
});
