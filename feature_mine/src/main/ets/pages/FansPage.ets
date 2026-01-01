import { VMManager } from "base_common"
import { FansPageVM } from "../viewmodels/FansPageVM"

@ComponentV2
export struct FansPage {
  @Local vm: FansPageVM = VMManager.get(FansPageVM, () => new FansPageVM());

  build() {
    NavDestination() {
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.start_window_background'))
  }
}