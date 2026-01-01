import { CommonConstant, RouterUtil, TransitionMap, VMManager } from 'base_common';
import { FloatButton } from 'base_ui';
import { FansTitleBar } from '../components/FansTitleBar';
import { FansPageVM } from '../viewmodels/FansPageVM';

@ComponentV2
export struct FansPage {
  @Local vm: FansPageVM = VMManager.get(FansPageVM, () => new FansPageVM());

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Column({ space: CommonConstant.NormalContainerInnerPadding }) {
          FansTitleBar({ vm: this.vm })
        }
        .width(CommonConstant.FullPercent)

        if (this.vm.isHideTitleBar) {
          FloatButton({ isFloating: this.vm.isHideTitleBar, floatIcon: $r('sys.symbol.magnifyingglass') })
            .geometryTransition(TransitionMap.FeatureMineFansSearch)
            .position({
              top: this.vm.window.windowTopPadding + (CommonConstant.TopBarHeight - CommonConstant.IconSizeLarge) / 2,
              right: CommonConstant.PageLRPadding
            })
            .onClick(() => {
              RouterUtil.pop()
            })
            .zIndex(2)
        }

        FloatButton({ isFloating: this.vm.isHideTitleBar })
          .position({
            top: this.vm.window.windowTopPadding + (CommonConstant.TopBarHeight - CommonConstant.IconSizeLarge) / 2,
            left: CommonConstant.PageLRPadding
          })
          .onClick(() => {
            RouterUtil.pop()
          })
          .zIndex(2)
      }
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.start_window_background'))
  }
}