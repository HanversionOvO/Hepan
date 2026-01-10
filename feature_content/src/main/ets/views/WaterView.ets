import { CommonConstant } from 'base_common';
import { FloatButton } from 'base_ui';
import { WaterVM } from '../viewmodels/WaterVM';

@ComponentV2
export struct WaterView {
  @Param @Require vm: WaterVM;

  @Builder
  WaterCard() {

  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row({ space: CommonConstant.NormalContainerInnerPadding }) {
        FloatButton()
        Text("水滴")
          .fontSize(CommonConstant.TextSizeLarge)
          .fontColor($r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Bold)
      }
      .padding({
        left: CommonConstant.PageLRPadding,
        top: this.vm.window.windowTopPadding
      })

      Flex({ direction: this.vm.isTabletView ? FlexDirection.Row : FlexDirection.Column }) {

      }
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
    }
    .backgroundColor($r('app.color.start_window_background'))
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
  }
}