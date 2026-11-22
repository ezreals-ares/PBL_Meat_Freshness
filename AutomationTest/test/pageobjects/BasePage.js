const { $, $$, driver } = require('@wdio/globals');

class BasePage {
  /**
   * Cari elemen Flutter/Android berdasarkan substring content-desc.
   * Flutter exposes Text dan Semantics label ke Android Accessibility via content-desc.
   */
  byDescContains(text) {
    const escaped = String(text).replace(/"/g, '\\"');
    return $(`android=new UiSelector().descriptionContains("${escaped}")`);
  }

  /**
   * Cari elemen Flutter/Android berdasarkan exact accessibility id / content-desc.
   */
  byDesc(text) {
    return $(`~${text}`);
  }

  async waitForVisible(element, timeout = 15000) {
    await element.waitForDisplayed({ timeout });
    return element;
  }

  async waitAndClick(element, timeout = 15000) {
    await element.waitForDisplayed({ timeout });
    await element.click();
  }

  // Bottom Navigation Bar (ShellScreen)
  // Menggunakan $$ + elemen terakhir untuk menghindari StrictSelectorError jika label yang sama muncul di body (mis. BERANDA / RIWAYAT)
  async clickBottomNav(label) {
    const escaped = String(label).replace(/"/g, '\\"');
    const selector = `android=new UiSelector().description("${escaped}")`;
    await $(selector, { strict: false }).waitForDisplayed({ timeout: 15000 });
    const matches = await $$(selector);
    const target = matches[matches.length - 1];
    await target.waitForDisplayed({ timeout: 15000 });
    await target.click();
  }

  async openBeranda() {
    await this.clickBottomNav('BERANDA');
  }

  async openPindai() {
    await this.clickBottomNav('PINDAI');
  }

  async openRiwayat() {
    await this.clickBottomNav('RIWAYAT');
  }

  async scrollDown(distance = 550) {
    const { width, height } = await driver.getWindowSize();
    const x = Math.round(width * 0.5);
    const startY = Math.round(height * 0.72);
    const endY = Math.max(100, startY - distance);
    await driver
      .action('pointer')
      .move({ duration: 0, x, y: startY })
      .down({ button: 0 })
      .move({ duration: 300, x, y: endY })
      .up({ button: 0 })
      .perform();
  }
}

module.exports = BasePage;
