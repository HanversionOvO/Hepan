import { CommonConstant } from 'base_common';
import { FloatButton } from 'base_ui';

@ComponentV2
export struct ChatBottomBar {
  @Param @Require controller: RichEditorController;

  build() {
    Row({ space: CommonConstant.NormalContainerInnerPadding }) {
      FloatButton({
        isFloating: true,
        floatIcon: $r('sys.symbol.picture')
      })

      RichEditor({
        controller: this.controller
      })
        .layoutWeight(1)
        .height(CommonConstant.IconSizeLarge)
        .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
        .borderRadius(CommonConstant.RadiusRound)
        .placeholder($r('app.string.ChatPage_send_placeholder'))

      FloatButton({
        isFloating: true,
        floatIcon: $r('sys.symbol.capture_smiles')
      })
    }
    .width(CommonConstant.FullPercent)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: CommonConstant.PageLRPadding,
      right: CommonConstant.PageLRPadding
    })
  }
}