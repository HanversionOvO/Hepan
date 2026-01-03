import { BaseVM, CommonConstant } from 'base_common';

@ComponentV2
export struct CustomAtPanel {
  @Param @Require vm: BaseVM;

  build() {
    Column({ space: CommonConstant.NormalContainerInnerPadding }) {
      Text($r('app.string.CustomAtPanel_title'))
        .width(CommonConstant.FullPercent)
        .fontSize(CommonConstant.TextSizeNormal)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Start)


    }
    .width(CommonConstant.FullPercent)
    .height(this.vm.window.windowHeight * 0.4)
    .backgroundColor($r('app.color.second_window_background'))
    .borderRadius({
      topLeft: CommonConstant.RadiusUltraLarge,
      topRight: CommonConstant.RadiusUltraLarge
    })
    .padding({
      left: CommonConstant.NormalContainerLRPadding,
      right: CommonConstant.NormalContainerLRPadding,
      top: CommonConstant.NormalContainerTBPadding,
      bottom: CommonConstant.NormalContainerTBPadding
    })
  }
}