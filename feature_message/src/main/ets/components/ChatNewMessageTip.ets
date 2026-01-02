import { CommonConstant } from 'base_common';
import { ChatPageVM } from '../viewmodels/ChatPageVM';

@ComponentV2
export struct ChatNewMessageTip {
  @Param @Require vm: ChatPageVM;
  @Param newMessageNum: number = 0;

  build() {
    Row({ space: CommonConstant.SmallContainerInnerPadding }) {
      SymbolGlyph($r('sys.symbol.chevron_down_circle'))
        .fontColor([CommonConstant.ThemeColor])
        .fontSize(CommonConstant.TextSizeSmall)

      Text($r('app.string.ChatPage_new_message'))
        .fontColor(CommonConstant.ThemeColor)
        .fontSize(CommonConstant.TextSizeSmall)
        .fontWeight(FontWeight.Bold)
    }
    .padding({
      left: CommonConstant.SmallContainerLRPadding,
      right: CommonConstant.SmallContainerLRPadding,
      top: CommonConstant.SmallContainerTBPadding,
      bottom: CommonConstant.SmallContainerTBPadding
    })
    .backgroundColor($r('app.color.second_window_background'))
    .borderRadius(CommonConstant.RadiusRound)
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THICK)
    .zIndex(3)
    .transition(
      TransitionEffect.OPACITY
        .combine(TransitionEffect.translate({ y: 10 }))
        .animation({ curve: CommonConstant.AnimationCurveSpring })
    )
    .onClick(() => {
      this.vm.chatScroller.scrollToIndex(this.vm.chats.length - 1, true);
    })
  }
}