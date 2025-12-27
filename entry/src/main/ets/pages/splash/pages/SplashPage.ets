import { VMManager } from 'base_common'
import { SplashPageVM } from '../viewmodels/SplashPageVM'

@Entry
@ComponentV2
struct SplashPage {
  @Local vm: SplashPageVM = VMManager.get(SplashPageVM);

  build() {
    Navigation()
      .hideTitleBar(true)
  }
}