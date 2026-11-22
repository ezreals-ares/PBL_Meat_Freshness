const BasePage = require('./BasePage');

class PreviewPage extends BasePage {
  get appBarTitle() {
    return this.byDescContains('PRATINJAU FOTO');
  }

  get modelSelectorLabel() {
    return this.byDescContains('PILIH MODEL AI');
  }

  get netv2ModelCard() {
    return this.byDescContains('MOBILENET V2');
  }

  get svmModelCard() {
    return this.byDescContains('SVM');
  }

  get chooseAnotherPhotoButton() {
    return this.byDescContains('PILIH FOTO LAIN');
  }

  get analyzeNetV2Button() {
    return this.byDescContains('ANALISIS (NETV2)');
  }

  get analyzeSvmButton() {
    return this.byDescContains('ANALISIS (SVM)');
  }

  async waitForScreenLoaded() {
    await this.waitForVisible(this.appBarTitle);
    await this.waitForVisible(this.modelSelectorLabel);
  }

  async selectNetV2() {
    await this.waitAndClick(this.netv2ModelCard);
  }

  async selectSvm() {
    await this.waitAndClick(this.svmModelCard);
  }
}

module.exports = new PreviewPage();
