const BasePage = require('./BasePage');

class HomePage extends BasePage {
  get appTitle() {
    return this.byDescContains('MEATFRESH AI');
  }

  get heroBanner() {
    return this.byDescContains('CEK KESEGARAN');
  }

  get startCheckButton() {
    return this.byDescContains('MULAI CEK');
  }

  get quickHistoryButton() {
    return this.byDescContains('SEMUA SCAN');
  }

  get quickUploadButton() {
    return this.byDescContains('DARI GALERI');
  }

  get safetyDisclaimer() {
    return this.byDescContains('INSPEKSI KEAMANAN PANGAN');
  }

  get storageRecommendation() {
    return this.byDescContains('REKOMENDASI PENYIMPANAN');
  }

  async waitForScreenLoaded() {
    await this.waitForVisible(this.appTitle);
    await this.waitForVisible(this.heroBanner);
  }

  async tapStartCheck() {
    await this.waitAndClick(this.startCheckButton);
  }

  async tapQuickHistory() {
    await this.waitAndClick(this.quickHistoryButton);
  }

  async tapQuickUpload() {
    await this.waitAndClick(this.quickUploadButton);
  }
}

module.exports = new HomePage();
