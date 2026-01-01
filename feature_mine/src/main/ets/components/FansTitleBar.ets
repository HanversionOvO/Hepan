import { CommonConstant } from 'base_common';
import { CustomSearch, CustomTabBar } from 'base_ui';
import { FansPageVM } from '../viewmodels/FansPageVM';

@ComponentV2
export struct FansTitleBar {
  @Param @Require vm: FansPageVM;
  @Local searchInputId: string = 'FansSearch';

  @Computed
  get tabLeftPadding(): number {
    if (this.vm.isTabletView && this.vm.isHideTitleBar) {
      return CommonConstant.IconSizeLarge + CommonConstant.NormalContainerInnerPadding;
    } else {
      return 0;
    }
  }

  build() {
    Column({ space: CommonConstant.SmallContainerInnerPadding }) {
      if (!this.vm.isHideTitleBar) {
        Column() {
          Row() {
            Text($r('app.string.FansPage_Title'))
              .fontWeight(FontWeight.Bold)
              .fontSize(CommonConstant.TextSizeNormal)
              .fontColor($r('sys.color.font_primary'))
              .textAlign(TextAlign.Center)
              .layoutWeight(1)
          }
          .width(CommonConstant.FullPercent)
          .height(CommonConstant.TopBarHeight)
          .alignItems(VerticalAlign.Center)

          CustomSearch({ searchKey: this.searchInputId })
        }
        .transition(TransitionEffect.move(TransitionEdge.TOP).combine(TransitionEffect.opacity(0)))
      }

      Row() {
        CustomTabBar({
          vm: this.vm,
          tabItems: this.vm.fansPageTabItems,
          currentIndex: this.vm.currentFansTabIndex,
          changeTab: (index: number) => {
            this.vm.changeFansTab(index);
          },
          alignMode: this.vm.isTabletView ? FlexAlign.Start : FlexAlign.Center
        })
      }
      .width(CommonConstant.FullPercent)
      .height(this.vm.isHideTitleBar ? CommonConstant.TopBarHeight : "auto")
      .padding({
        left: this.tabLeftPadding
      })
    }
    .width(CommonConstant.FullPercent)
    .padding({
      top: this.vm.window.windowTopPadding,
      left: CommonConstant.PageLRPadding,
      right: CommonConstant.PageLRPadding
    })
    .backgroundColor($r('app.color.start_window_background'))
  }
}