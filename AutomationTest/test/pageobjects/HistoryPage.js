const { $, driver } = require('@wdio/globals');
const BasePage = require('./BasePage');

class HistoryPage extends BasePage {
  get headerTitle() {
    return this.byDescContains('RIWAYAT SCAN');
  }

  get sampleCountText() {
    return this.byDescContains('SAMPEL DIANALISIS');
  }

  get exportButton() {
    return this.byDescContains('EKSPOR');
  }

  get searchInput() {
    return $('android=new UiSelector().className("android.widget.EditText")');
  }

  get filterAll() {
    return $('android=new UiSelector().descriptionMatches("^SEMUA \\(\\d+\\)$")');
  }

  get filterFresh() {
    return $('android=new UiSelector().descriptionMatches("^SEGAR \\(\\d+\\)$")');
  }

  get filterHalfFresh() {
    return $('android=new UiSelector().descriptionMatches("^SETENGAH SEGAR \\(\\d+\\)$")');
  }

  get filterSpoiled() {
    return $('android=new UiSelector().descriptionMatches("^BUSUK \\(\\d+\\)$")');
  }

  get emptyStateTitle() {
    return this.byDescContains('BELUM ADA CEK');
  }

  get resetFilterButton() {
    return this.byDescContains('RESET FILTER');
  }

  async waitForScreenLoaded() {
    await this.waitForVisible(this.headerTitle);
    await this.waitForVisible(this.sampleCountText);
  }

  async search(query) {
    await this.waitForVisible(this.searchInput);
    await this.searchInput.click();
    await this.searchInput.setValue(query);
  }

  async tapResetFilter() {
    await this.waitAndClick(this.resetFilterButton);
  }

  async scrollFiltersToEnd() {
    const anchor = await this.filterHalfFresh;
    const loc = await anchor.getLocation();
    const size = await anchor.getSize();
    const y = Math.round(loc.y + size.height / 2);
    const startX = Math.round(loc.x + size.width * 0.8);
    const endX = Math.max(20, Math.round(loc.x - 250));
    await driver
      .action('pointer')
      .move({ duration: 0, x: startX, y })
      .down({ button: 0 })
      .move({ duration: 300, x: endX, y })
      .up({ button: 0 })
      .perform();
  }
}

module.exports = new HistoryPage();
