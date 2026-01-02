import { BaseVM, CommonConstant } from 'base_common';
import { CustomTabBar, CustomTabItem } from './CustomTabBar';

@ComponentV2
export struct CustomFacePanel {
  @Param @Require vm: BaseVM;
  @Param faceCollections: CustomTabItem[] = [];

  build() {
    Column({ space: CommonConstant.NormalContainerInnerPadding }) {
      CustomTabBar({
        vm: this.vm,
        tabItems: this.faceCollections,
        isMax: true,
        alignMode: FlexAlign.Start
      })

      Tabs() {

      }
      .layoutWeight(1)
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