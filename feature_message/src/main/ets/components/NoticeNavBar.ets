import { CommonConstant } from 'base_common';
import { NoticePageVM } from '../viewmodels/NoticePageVM';

@ComponentV2
export struct NoticeNavBar {
  @Param @Require vm: NoticePageVM;

  build() {
    Row() {
      Text(this.vm.messageNotifyCard?.cardTitle)
        .fontSize(CommonConstant.TextSizeUltraLarge)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_on_primary'))
        .transition(TransitionEffect.OPACITY.animation({ duration: CommonConstant.AnimationDurationNormal }))

      SymbolGlyph(this.vm.messageNotifyCard?.icon)
        .fontSize(CommonConstant.IconSizeUltraLarge * 2)
        .fontColor([$r('sys.color.font_tertiary')])
        .opacity(CommonConstant.IconOpacity)
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.TopBarHeight + this.vm.window.windowTopPadding)
    .justifyContent(FlexAlign.SpaceBetween)
    .clip(true)
    .backgroundColor(this.vm.messageNotifyCard?.iconColor)
    .zIndex(1)
    .padding({
      top: this.vm.window.windowTopPadding,
      left: CommonConstant.PageLRPadding + CommonConstant.IconSizeLarge + CommonConstant.NormalContainerInnerPadding,
      right: CommonConstant.PageLRPadding
    })
    .transition(TransitionEffect.move(TransitionEdge.TOP).combine(TransitionEffect.opacity(0)))
  }
}