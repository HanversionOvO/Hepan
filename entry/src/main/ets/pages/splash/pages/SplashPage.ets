import { ResUtil } from '@pura/harmony-utils';
import { CommonConstant, RouterUtil, VMManager } from 'base_common';
import { GlassButton, LoneTakeAnimationsTransition } from 'base_ui';
import { SplashPageVM } from '../viewmodels/SplashPageVM';

@Entry
@ComponentV2
struct SplashPage {
  @Local vm: SplashPageVM = new SplashPageVM()
  @Local logoSize: number = 96;

  aboutToAppear(): void {
    this.vm.startSplash();
  }

  aboutToDisappear(): void {
    this.vm.stopSplash();

    VMManager.destroy(SplashPageVM);
  }

  build() {
    Navigation(RouterUtil.getStack()) {
      Column() {
        Row() {
          GlassButton({
            text: `${ResUtil.getStringSync($r('app.string.Splash_skip'))} ${this.vm.countDown}`,
            innerFontSize: CommonConstant.TextSizeSmall
          })
            .onClick(() => {
              this.vm.onSkip()
            })
        }
        .width(CommonConstant.FullPercent)
        .justifyContent(FlexAlign.End)

        Row() {
          Image($r('app.media.startIcon'))
            .width(this.logoSize)
            .height(this.logoSize)
            .borderRadius(CommonConstant.RadiusUltraLarge)
        }
        .layoutWeight(1)
        .width(CommonConstant.FullPercent)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)

        Column({
          space: CommonConstant.NormalContainerInnerPadding
        }) {
          Text($r('app.string.EntryAbility_label'))
            .fontSize(CommonConstant.TextSizeUltraLarge)
            .fontWeight(FontWeight.Bolder)
            .fontColor($r('sys.color.font_primary'))
            .letterSpacing(1)

          Row({ space: CommonConstant.SmallContainerInnerPadding }) {
            Divider()
              .vertical(false)
              .width(12)
              .color($r('sys.color.font_secondary'))
              .strokeWidth(1)
            Text($r('app.string.EntryAbility_desc'))
              .fontSize(CommonConstant.TextSizeSmall)
              .fontColor($r('sys.color.font_secondary'))
              .fontWeight(FontWeight.Medium)
              .letterSpacing(2)
            Divider()
              .vertical(false)
              .width(12)
              .color($r('sys.color.font_secondary'))
              .strokeWidth(1)
          }

          Text(`© 2025 ${ResUtil.getStringSync($r('app.string.App_author'))}`)
            .fontSize(CommonConstant.TextSizeTiny)
            .fontColor($r('sys.color.font_tertiary'))
        }
        .width(CommonConstant.FullPercent)
      }
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
      .padding({
        top: this.vm.window.windowTopPadding + CommonConstant.TopBarHeight,
        bottom: this.vm.window.windowBottomPadding + CommonConstant.BottomBarHeight,
        left: CommonConstant.PageLRPadding,
        right: CommonConstant.PageLRPadding
      })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .hideTitleBar(true)
    .hideNavBar(!this.vm.window.showNavigation)
    .height(CommonConstant.FullPercent)
    .width(CommonConstant.FullPercent)
    .enabled(this.vm.isEnabled)
    .mode(NavigationMode.Stack)
    .backgroundColor($r('app.color.start_window_background'))
    .customNavContentTransition((from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation) => {
      return LoneTakeAnimationsTransition.customNavContentTransition(from, to, operation, {
        onTransitionStart: () => {
          this.vm.isEnabled = false;
        },
        onTransitionEnd: () => {
          this.vm.isEnabled = true;
        }
      });
    })
  }
}