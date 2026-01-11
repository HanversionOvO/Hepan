import { AppUtil } from '@pura/harmony-utils';
import { CommonConstant, InputOverlayStore, InputOverlayVisibilityEvent } from 'base_common';
import { HomePageVM } from '../viewmodels/HomePageVM';
import { window } from '@kit.ArkUI';

const TAG = "[HomeNavBar]: ";

export interface HomeNavBarItem {
  name: string;
  icon: Resource;
  title: ResourceStr;
}

@ComponentV2
export struct HomeNavBar {
  @Param @Require vm: HomePageVM;
  @Local NavBarItemPadding: number = CommonConstant.SmallContainerInnerPadding;
  @Local NavBarItemOffset: number = this.NavBarItemPadding;

  @Computed
  get navBarTransition(): TransitionEffect {
    const baseEffect = TransitionEffect.translate({ y: this.navBarSize })
      .combine(TransitionEffect.opacity(0));

    return TransitionEffect.asymmetric(
      baseEffect.animation({
        curve: CommonConstant.AnimationCurveSpring,
        duration: CommonConstant.AnimationDurationNormal
      }),
      baseEffect.animation({
        curve: Curve.EaseOut,
        duration: CommonConstant.AnimationDurationNormal
      })
    );
  }

  @Computed
  get navBarSize(): number {
    return this.vm.window.windowBottomPadding + CommonConstant.BottomBarHeight;
  }

  @Computed
  get availableLength(): number {
    if (this.vm.isTabletView) {
      return this.vm.window.windowHeight - this.vm.window.windowTopPadding;
    } else {
      return this.vm.window.windowWidth;
    }
  }

  @Computed
  get navRectWidth(): number {
    return this.vm.isTabletView ? CommonConstant.BottomBarHeight - (this.NavBarItemPadding * 2) :
      (this.availableLength / this.vm.homeNavBarItem.length) - (this.NavBarItemPadding * 2)
  }

  @Computed
  get navRectHeight(): number {
    return this.vm.isTabletView ?
      (this.availableLength / this.vm.homeNavBarItem.length) - (this.NavBarItemPadding * 2) :
      CommonConstant.BottomBarHeight - (this.NavBarItemPadding * 2)
  }

  @Computed
  get navRectMarginBottom(): number {
    return this.vm.isTabletView ? 0 : this.NavBarItemPadding;
  }

  @Computed
  get navBarBgColor(): ResourceColor {
    return $r("app.color.glass_background");
  }

  @Monitor("vm.breakPoint.currentBreakPoint","vm.window.windowWidth","vm.window.windowHeight")
  updateLayout() {
    this.calculateOffset(this.vm.currentIndex);
  }

  aboutToAppear(): void {
    window.getLastWindow(this.getUIContext().getHostContext()).then(currentWindow => {
      currentWindow.on('keyboardHeightChange', (data: number) => {
        InputOverlayStore.emit(InputOverlayVisibilityEvent, data > 0);
      })
    })
  }

  aboutToDisappear(): void {
    window.getLastWindow(this.getUIContext().getHostContext()).then(currentWindow => {
      currentWindow.off('keyboardHeightChange');
    })
  }

  private calculateOffset(index: number) {
    const step = this.availableLength / this.vm.homeNavBarItem.length;
    this.NavBarItemOffset = this.NavBarItemPadding + step * index;
  }

  private runChangeNavAnimation(index: number) {
    AppUtil.getUIContext().animateTo({
      curve: CommonConstant.AnimationCurveSpring,
      duration: CommonConstant.AnimationDurationNormal
    }, () => {
      this.vm.changeNavBar(index);
      this.calculateOffset(index);
    })
  }

  build() {
    if (this.vm.isNavBarVisible) {
      Stack({
        alignContent: this.vm.isTabletView ? Alignment.Top : Alignment.BottomStart
      }) {
        Rect()
          .radius(CommonConstant.RadiusNormal)
          .width(this.navRectWidth)
          .height(this.navRectHeight)
          .fill(CommonConstant.ThemeColor)
          .margin({
            top: this.vm.isTabletView ? (this.NavBarItemOffset + this.vm.window.windowTopPadding) : 0,
            bottom: this.navRectMarginBottom,
            left: this.vm.isTabletView ? 0 : this.NavBarItemOffset
          })

        Flex({
          direction: this.vm.isTabletView ? FlexDirection.Column : FlexDirection.Row,
          alignItems: ItemAlign.Center,
          justifyContent: this.vm.isTabletView ? FlexAlign.Start : FlexAlign.SpaceBetween
        }) {
          ForEach(this.vm.homeNavBarItem, (item: HomeNavBarItem, index: number) => {
            Column({ space: CommonConstant.SmallContainerInnerPadding / 2 }) {
              SymbolGlyph(item.icon)
                .fontSize(CommonConstant.IconSizeNormal)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.vm.currentIndex === index ? [$r('sys.color.font_on_primary')] :
                  [$r('sys.color.font_secondary')])
                .animation({ duration: CommonConstant.AnimationDurationNormal })
              Text(item.title)
                .fontSize(CommonConstant.TextSizeTiny)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.vm.currentIndex === index ? $r('sys.color.font_on_primary') :
                  $r('sys.color.font_secondary'))
                .animation({ duration: CommonConstant.AnimationDurationNormal })
            }
            .layoutWeight(1)
            .width(this.vm.isTabletView ? CommonConstant.FullPercent : undefined)
            .height(this.vm.isTabletView ? undefined : CommonConstant.FullPercent)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.runChangeNavAnimation(index);
            })
          })
        }
        .margin({
          top: this.vm.isTabletView ? this.vm.window.windowTopPadding : 0
        })
      }
      .width(this.vm.isTabletView ? CommonConstant.BottomBarHeight : CommonConstant.FullPercent)
      .height(this.vm.isTabletView ? CommonConstant.FullPercent : this.navBarSize)
      .padding({
        bottom: this.vm.isTabletView ? 0 : this.vm.window.windowBottomPadding,
      })
      .backgroundColor(this.navBarBgColor)
      .backgroundBlurStyle(BlurStyle.BACKGROUND_ULTRA_THICK)
      .transition(this.vm.isTabletView ? undefined : this.navBarTransition)
    }
  }
}
