import { BaseVM } from 'base_common';

@ObservedV2
export class HomePageVM extends BaseVM {
  startHome() {
    setTimeout(() => {
      this.window.showNavigation = false
    }, 50)
  }
}