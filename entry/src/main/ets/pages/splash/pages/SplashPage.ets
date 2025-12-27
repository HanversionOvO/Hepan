import { CommonConstant, RouterUtil, VMManager } from 'base_common'
import { GlassButton } from 'base_ui';
import { SplashPageVM } from '../viewmodels/SplashPageVM'

@Entry
@ComponentV2
struct SplashPage {
  @Local vm: SplashPageVM = VMManager.get(SplashPageVM, () => new SplashPageVM());

  aboutToAppear(): void {
    this.vm.startSplash();
  }

  aboutToDisappear(): void {
    this.vm.stopSplash();

    VMManager.destroy(SplashPageVM);
  }

  build() {
    Navigation(RouterUtil.getStack()) {

      Column() {
        GlassButton({
          text: "test"
        })
      }
    }
    .hideTitleBar(true)
    .hideNavBar(this.vm.window.showNavigation)
    .height(CommonConstant.FullPercent)
    .width(CommonConstant.FullPercent)
    .mode(NavigationMode.Stack)
    .backgroundColor($r('app.color.start_window_background'))
  }
}