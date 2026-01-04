import { AppUtil } from '@pura/harmony-utils';
import { CommonConstant, VMManager } from 'base_common';
import { CustomTabBar, FloatButton } from 'base_ui';
import { TieVM } from '../viewmodels/TieVM';

@ComponentV2
export struct TieView {
  @Local vm: TieVM = VMManager.get(TieVM, () => new TieVM())
  @Consumer("isHideNavTitle") isHideNavTitle: boolean = false;
  @Consumer("isHideTabBar") isHideTabBar: boolean = false;

  @Computed
  get topHeightNav(): number {
    return CommonConstant.TopBarHeight + this.vm.window.windowTopPadding + CommonConstant.IconSizeLarge +
    CommonConstant.NormalContainerInnerPadding
  }

  @Computed
  get topHeightTab(): number {
    return this.topHeightNav + CommonConstant.IconSizeLarge + CommonConstant.SmallContainerInnerPadding * 2 +
      CommonConstant.BorderSizeNormal * 2 + CommonConstant.NormalContainerInnerPadding;
  }

  @Computed
  get topHideNav(): number {
    return this.vm.window.windowTopPadding +
      (CommonConstant.TopBarHeight - (CommonConstant.IconSizeLarge + CommonConstant.SmallContainerInnerPadding * 2 +
        CommonConstant.BorderSizeNormal * 2)) / 2
  }

  private handleScroll(yOffset: number, scrollState: ScrollState) {
    if (scrollState === ScrollState.Scroll) {
      if (yOffset > CommonConstant.ScrollAnimationThreshold) {
        AppUtil.getUIContext()
          .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring },
            () => {
              this.isHideNavTitle = true;
              this.isHideTabBar = true;
            })
      } else if (yOffset < -CommonConstant.ScrollAnimationThreshold) {
        AppUtil.getUIContext()
          .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring },
            () => {
              this.isHideNavTitle = false;
              this.isHideTabBar = false;
            })
      }
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        if (!this.isHideNavTitle) {
          Column()
            .height(this.topHeightTab)
        }

        List({ space: CommonConstant.NormalContainerInnerPadding }) {
          ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], (item: number) => {
            ListItem() {
              Column()
                .width(CommonConstant.FullPercent)
                .height(240)
                .backgroundColor($r('app.color.second_window_background'))
                .borderRadius(CommonConstant.RadiusUltraLarge)
            }
          }, (item: number) => item.toString())
        }
        .width(CommonConstant.FullPercent)
        .layoutWeight(1)
        .onDidScroll((scrollOffset, scrollState) => {
          this.handleScroll(scrollOffset, scrollState);
        })
      }
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)

      Column() {
        if (!this.isHideNavTitle) {
          Column()
            .height(this.topHeightNav)
        } else {
          Column()
            .height(this.topHideNav)
        }

        Row({ space: CommonConstant.NormalContainerInnerPadding }) {
          if (this.isHideNavTitle && this.vm.isTabletView) {
            Text($r('app.string.ContentPage_title'))
              .fontSize(CommonConstant.TextSizeUltraLarge)
              .opacity(0)
              .hitTestBehavior(HitTestMode.Transparent)
              .margin({
                right: CommonConstant.NormalContainerInnerPadding * 3
              })
          }

          Row() {
            CustomTabBar({
              vm: this.vm,
              tabItems: this.vm.categoryTabItems,
              isMax: true,
              isGlassStyle: true,
              alignMode: this.vm.isTabletView ? FlexAlign.Start : FlexAlign.Center
            })
          }
          .layoutWeight(1)

          if (this.isHideNavTitle && this.vm.isTabletView) {
            FloatButton()
              .opacity(0)
              .hitTestBehavior(HitTestMode.Transparent)
          }
        }
        .zIndex(999)
      }
      .width(CommonConstant.FullPercent)
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
    .padding({
      left: CommonConstant.PageLRPadding,
      right: CommonConstant.PageLRPadding
    })
  }
}