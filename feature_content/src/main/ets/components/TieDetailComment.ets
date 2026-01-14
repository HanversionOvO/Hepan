import { CommonConstant, RouterUtil, TransitionMap } from 'base_common';
import { TieContentPageVM } from '../viewmodels/TieContentPageVM';
import { tieCollectSheet } from './TieCollectSheet';

@ComponentV2
export struct TieDetailComment {
  @Param @Require vm: TieContentPageVM;
  @Param @Require sideNavWidth: number;
  @Local isLiked: boolean = false;
  @Local isDisliked: boolean = false;
  @Local likeScale: number = 1;
  @Local dislikeScale: number = 1;

  aboutToAppear(): void {
    this.syncState();
  }

  syncState() {
    this.isLiked = false;
    this.isDisliked = false;
  }

  build() {
    Row({ space: CommonConstant.NormalContainerInnerPadding }) {
      Row({ space: CommonConstant.SmallContainerInnerPadding }) {
        SymbolGlyph($r('sys.symbol.pencil_and_card'))
          .fontSize(CommonConstant.TextSizeNormal)
          .fontColor([$r('sys.color.font_tertiary')])

        Text($r('app.string.TieContentPage_say'))
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
        const threadId = this.vm.tieThread.thread_id || this.vm.tieSummary.thread_id;
        if (threadId) {
          RouterUtil.pushPathByName("ReplyPage", { "threadId": threadId } as Record<string, Object>,
            undefined, false);
        }
      })

      Row({ space: CommonConstant.NormalContainerInnerPadding }) {
        SymbolGlyph(this.isLiked ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'))
          .fontColor(this.isLiked ? [CommonConstant.ThemeColor] : [$r('sys.color.font_tertiary')])
          .fontSize(CommonConstant.IconSizeSmall)
          .scale({ x: this.likeScale, y: this.likeScale })
          .animation({
            duration: CommonConstant.AnimationDurationNormal,
            curve: CommonConstant.AnimationCurveSpring
          })
          .onClick(() => {
            this.isLiked = !this.isLiked;

            this.likeScale = 0.7;
            setTimeout(() => {
              this.likeScale = 1.2;
              setTimeout(() => this.likeScale = 1, 150);
            }, 100);

            this.vm.supportTie(true);
          })

        SymbolGlyph($r('sys.symbol.star'))
          .fontColor([$r('sys.color.font_tertiary')])
          .fontSize(CommonConstant.IconSizeSmall)
          .onClick(async () => {
            this.vm.isShowCollectSheet = true;
          })
          .bindSheet($$this.vm.isShowCollectSheet, tieCollectSheet(this.vm), {
            showClose: true,
            detents: [SheetSize.FIT_CONTENT],
            enableOutsideInteractive: false,
            preferType: this.vm.isTabletView ? SheetType.CENTER : SheetType.BOTTOM,
            backgroundColor: $r('app.color.start_window_background'),
            blurStyle: BlurStyle.BACKGROUND_ULTRA_THICK,
            title: {
              title: $r('app.string.TieContentPage_collect_tie')
            }
          })

        SymbolGlyph(this.isDisliked ? $r('sys.symbol.hand_thumbsdown_fill') : $r('sys.symbol.hand_thumbsdown'))
          .fontColor(this.isDisliked ? [CommonConstant.InfoColor] : [$r('sys.color.font_tertiary')])
          .fontSize(CommonConstant.IconSizeSmall)
          .scale({ x: this.dislikeScale, y: this.dislikeScale })
          .animation({
            duration: CommonConstant.AnimationDurationNormal,
            curve: CommonConstant.AnimationCurveSpring
          })
          .onClick(() => {
            this.isDisliked = !this.isDisliked;

            this.dislikeScale = 0.7;
            setTimeout(() => {
              this.dislikeScale = 1.2;
              setTimeout(() => this.dislikeScale = 1, 150);
            }, 100);

            this.vm.supportTie(false);
          })
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
    .expandSafeArea([SafeAreaType.KEYBOARD])
  }
}
