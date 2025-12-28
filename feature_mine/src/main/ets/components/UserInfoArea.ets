import { MinePageVM } from '../viewmodels/MinePageVM';
import { LengthMetrics } from '@kit.ArkUI';
import { CommonConstant } from 'base_common';

@ComponentV2
export struct UserInfoArea {
  @Param @Require vm: MinePageVM;

  build() {
    Flex({
      direction: this.vm.isTabletView ? FlexDirection.Row : FlexDirection.Column,
      space: {
        main: this.vm.isTabletView ? LengthMetrics.vp(CommonConstant.NormalContainerInnerPadding) :
          LengthMetrics.vp(CommonConstant.NormalContainerInnerPadding)
      },
      alignItems: ItemAlign.Center
    }) {

    }
    .width(CommonConstant.FullPercent)
    .padding({
      top: CommonConstant.TopBarHeight * 2 + this.vm.window.windowTopPadding
    })
  }
}