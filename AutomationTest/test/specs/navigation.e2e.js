const { expect } = require('@wdio/globals');
const HomePage = require('../pageobjects/HomePage');
const CapturePage = require('../pageobjects/CapturePage');
const HistoryPage = require('../pageobjects/HistoryPage');

describe('Navigasi Utama & Aksi Cepat - MeatFresh AI', () => {
  beforeEach(async () => {
    await HomePage.waitForScreenLoaded();
  });

  it('harus dapat berpindah antar tab bottom navigation (BERANDA -> PINDAI -> RIWAYAT -> BERANDA)', async () => {
    await HomePage.openPindai();
    await CapturePage.waitForScreenLoaded();
    await expect(CapturePage.headerTitle).toBeDisplayed();

    await CapturePage.openRiwayat();
    await HistoryPage.waitForScreenLoaded();
    await expect(HistoryPage.headerTitle).toBeDisplayed();

    await HistoryPage.openBeranda();
    await HomePage.waitForScreenLoaded();
    await expect(HomePage.heroBanner).toBeDisplayed();
  });

  it('tombol MULAI CEK di beranda harus membuka halaman Pindai', async () => {
    await HomePage.tapStartCheck();
    await CapturePage.waitForScreenLoaded();
    await expect(CapturePage.targetBadge).toBeDisplayed();

    await CapturePage.openBeranda();
  });

  it('kartu aksi cepat SEMUA SCAN harus membuka halaman Riwayat', async () => {
    await HomePage.tapQuickHistory();
    await HistoryPage.waitForScreenLoaded();
    await expect(HistoryPage.headerTitle).toBeDisplayed();

    await HistoryPage.openBeranda();
  });
});
