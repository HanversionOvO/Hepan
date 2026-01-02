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

      Row({ space: CommonConstant.NormalContainerInnerPadding }) {
        RichEditor({
          controller: this.controller
        })
          .constraintSize({
            minHeight: CommonConstant.IconSizeLarge,
            maxHeight: CommonConstant.IconSizeLarge * 3
          })
          .barState(BarState.Off)
          .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
          .borderRadius(CommonConstant.IconSizeLarge)
          .placeholder($r('app.string.ChatPage_send_placeholder'), {
            font: {
              size: CommonConstant.TextSizeNormal
            }
          })
          .caretColor(CommonConstant.ThemeColor)
          .layoutWeight(1)
          .onReady(() => {
            this.controller.setTypingStyle({
              fontSize: CommonConstant.TextSizeNormal,
              fontColor: $r('sys.color.font_primary')
            })
          })

        Row() {
          SymbolGlyph($r('sys.symbol.paperplane'))
            .fontSize(CommonConstant.TextSizeLarge)
            .fontWeight(FontWeight.Bold)
            .fontColor([$r('sys.color.font_on_primary')])
        }
        .width(CommonConstant.IconSizeLarge)
        .height(CommonConstant.IconSizeLarge)
        .borderRadius(CommonConstant.RadiusRound)
        .backgroundColor(CommonConstant.ThemeColor)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Bottom)

      FloatButton({
        isFloating: true,
        floatIcon: $r('sys.symbol.capture_smiles')
      })
    }
    .width(CommonConstant.FullPercent)
    .justifyContent(FlexAlign.SpaceBetween)
    .transition(TransitionEffect.move(TransitionEdge.BOTTOM).combine(TransitionEffect.opacity(0)))
    .animation({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring })
    .padding({
      left: CommonConstant.PageLRPadding,
      right: CommonConstant.PageLRPadding
    })
    .alignItems(VerticalAlign.Bottom)
  }
}