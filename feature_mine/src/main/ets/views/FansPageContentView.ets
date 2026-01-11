import { CommonConstant } from 'base_common';
import { FansTitleBar } from '../components/FansTitleBar';
import { FansUserSection } from '../components/FansUserSection';
import { FansPageVM } from '../viewmodels/FansPageVM';

@ComponentV2
export struct FansPageContentView {
  @Param @Require vm: FansPageVM;

  build() {
    Column({ space: CommonConstant.NormalContainerInnerPadding }) {
      FansTitleBar({ vm: this.vm })

      Tabs({ controller: this.vm.fansPageTabController, index: this.vm.currentFansTabIndex }) {
        TabContent() {
          FansUserSection({ vm: this.vm, isFollowList: true })
        }

        TabContent() {
          FansUserSection({ vm: this.vm, isFollowList: false })
        }
      }
      .padding({
        left: CommonConstant.PageLRPadding,
        right: CommonConstant.PageLRPadding,
      })
      .width(CommonConstant.FullPercent)
      .layoutWeight(1)
      .barHeight(0)
      .scrollable(false)
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
  }
}
