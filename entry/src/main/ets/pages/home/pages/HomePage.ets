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
    NavDestination() {
      Stack({ alignContent: this.vm.isTabletView ? Alignment.Start : Alignment.Top }) {
        Text(this.vm.isTabletView ? "test" : "ests")

      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.start_window_background'))
    .onShown(() => {
      this.vm.startHome();
    })
  }
}