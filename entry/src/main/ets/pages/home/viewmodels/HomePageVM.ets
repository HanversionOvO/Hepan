import { BaseVM, StorageManager } from 'base_common';

@ObservedV2
export class HomePageVM extends BaseVM {
  @Trace currentHomaPageIndex: number = StorageManager.homePageIndexModel.currentIndex;

  startHome() {
    setTimeout(() => {
      this.window.showNavigation = false
    }, 50)
  }
}