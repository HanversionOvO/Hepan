import { CommonConstant, RouterUtil, TransitionMap } from 'base_common';
import { FloatButton } from 'base_ui';
import { FansPageVM } from '../viewmodels/FansPageVM';

@ComponentV2
export struct FansPageActionsView {
  @Param @Require vm: FansPageVM;

  build() {
    Stack() {
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
  }
}
