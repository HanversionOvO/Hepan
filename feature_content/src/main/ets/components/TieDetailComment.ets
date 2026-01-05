import { CommonConstant, TransitionMap } from 'base_common';
import { TieContentPageVM } from '../viewmodels/TieContentPageVM';

@ComponentV2
export struct TieDetailComment {
  @Param @Require vm: TieContentPageVM;
  @Param @Require sideNavWidth: number;

  build() {
    Row({ space: CommonConstant.NormalContainerInnerPadding }) {
      Row({ space: CommonConstant.SmallContainerInnerPadding }) {
        SymbolGlyph($r('sys.symbol.pencil_and_card'))
          .fontSize(CommonConstant.TextSizeNormal)
          .fontColor([$r('sys.color.font_tertiary')])

        Text("说点什么吧...")
          .fontSize(CommonConstant.TextSizeNormal)
          .fontColor($r('sys.color.font_tertiary'))
      }
      .height(CommonConstant.IconSizeLarge)
      .padding({
        left: CommonConstant.NormalContainerLRPadding,
        right: CommonConstant.NormalContainerLRPadding
      })
      .borderRadius(CommonConstant.RadiusRound)
      .backgroundColor($r('app.color.second_window_background'))
      .justifyContent(FlexAlign.Start)
      .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
      .layoutWeight(1)
      .geometryTransition(TransitionMap.TieDetailComment)
      .transition(TransitionEffect.OPACITY.animation({ duration: CommonConstant.AnimationDurationNormal }))
      .onClick(() => {
        // RouterUtil.pushPathByName(RouterMap.COMMENT_REPLY_DIALOG, null, undefined, false);
      })

      Row({ space: CommonConstant.NormalContainerInnerPadding }) {
        SymbolGlyph($r('sys.symbol.heart'))
          .fontColor([$r('sys.color.font_tertiary')])
          .fontSize(CommonConstant.IconSizeSmall)

        SymbolGlyph($r('sys.symbol.star'))
          .fontColor([$r('sys.color.font_tertiary')])
          .fontSize(CommonConstant.IconSizeSmall)

        SymbolGlyph($r('sys.symbol.hand_thumbsdown'))
          .fontColor([$r('sys.color.font_tertiary')])
          .fontSize(CommonConstant.IconSizeSmall)
      }
    }
    .width(this.vm.isTabletView ? this.sideNavWidth - CommonConstant.PageLRPadding * 2 : "92%")
    .borderRadius(CommonConstant.RadiusRound)
    .backgroundColor(Color.Transparent)
    .backgroundBlurStyle(this.vm.isTabletView && this.vm.isReachEnd ? BlurStyle.NONE : BlurStyle.BACKGROUND_ULTRA_THICK)
    .padding({
      left: this.vm.isTabletView && this.vm.isReachEnd ? 0 : CommonConstant.SmallContainerInnerPadding,
      right: this.vm.isTabletView && this.vm.isReachEnd ? 0 : CommonConstant.SmallContainerLRPadding,
      top: this.vm.isTabletView && this.vm.isReachEnd ? 0 : CommonConstant.SmallContainerInnerPadding,
      bottom: this.vm.isTabletView && this.vm.isReachEnd ? 0 : CommonConstant.SmallContainerInnerPadding
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({
      bottom: this.vm.window.windowBottomPadding
    })
    .border(this.vm.isTabletView && this.vm.isReachEnd ? { width: 0 } :
      { width: CommonConstant.BorderSizeNormal, color: $r('app.color.glass_border') })
    .animation({
      duration: CommonConstant.AnimationDurationNormal,
      curve: CommonConstant.AnimationCurveSpring
    })
  }
}