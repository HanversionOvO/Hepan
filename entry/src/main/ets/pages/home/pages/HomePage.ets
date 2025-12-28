import { VMManager } from 'base_common'
import { HomePageVM } from '../viewmodels/HomePageVM'

@Builder
export function HomePageBuilder() {
  HomePage()
}

@ComponentV2
struct HomePage {
  @Local vm: HomePageVM = VMManager.get(HomePageVM, () => new HomePageVM())

  build() {
    NavDestination()
      .hideTitleBar(true)
      .backgroundColor($r('app.color.start_window_background'))
      .onShown(() => {
        this.vm.startHome();
      })
  }
}