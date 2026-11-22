const BasePage = require('./BasePage');

class CapturePage extends BasePage {
  get headerSubtitle() {
    return this.byDescContains('ANALISIS VISUAL');
  }

  get headerTitle() {
    return this.byDescContains('AMBIL ATAU PILIH');
  }

  get targetBadge() {
    return this.byDescContains('TARGET: DAGING');
  }

  get cameraCard() {
    return this.byDescContains('AMBIL FOTO');
  }

  get galleryCard() {
    return this.byDescContains('UNGGAH FOTO');
  }

  async waitForScreenLoaded() {
    await this.waitForVisible(this.headerSubtitle);
    await this.waitForVisible(this.headerTitle);
  }

  async tapCameraCard() {
    await this.waitAndClick(this.cameraCard);
  }

  async tapGalleryCard() {
    await this.waitAndClick(this.galleryCard);
  }
}

module.exports = new CapturePage();
