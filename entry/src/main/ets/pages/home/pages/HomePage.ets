import { CommonConstant, VMManager } from 'base_common';
import { MinePageImpl } from 'feature_mine';
import { HomeNavBar } from '../components/HomeNavBar';
import { HomePageVM } from '../viewmodels/HomePageVM';
import { MessagePageImpl } from 'feature_message';
import { PostPageImpl } from 'feature_post';
import { ContentPageImpl } from 'feature_content';

@Builder
export function HomePageBuilder() {
  HomePage()
}

@ComponentV2
struct HomePage {
  @Local vm: HomePageVM = new HomePageVM()

  aboutToDisappear(): void {
    this.vm.aboutToDisappear();
  }

  build() {
    NavDestination() {
      Stack({ alignContent: this.vm.isTabletView ? Alignment.Start : Alignment.Bottom }) {
        Tabs({ index: this.vm.currentIndex, controller: this.vm.controller }) {
          TabContent() {
            ContentPageImpl()
          }

          TabContent() {
            PostPageImpl()
          }

          TabContent() {
            MessagePageImpl()
          }

          TabContent() {
            MinePageImpl()
          }
        }
        .barHeight(0)
        .scrollable(false)
        .width(CommonConstant.FullPercent)
        .height(CommonConstant.FullPercent)
        .padding({
          left: this.vm.isTabletView ? CommonConstant.BottomBarHeight : 0
        })

        HomeNavBar({ vm: this.vm })
      }
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
      .animation({ duration: CommonConstant.AnimationDurationNormal })
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.start_window_background'))
    .onShown(() => {
      this.vm.startHome();
    })
  }
}