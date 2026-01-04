// 文件: base_ui/src/main/ets/components/CollapsibleCoordinator.ets

import { AppUtil } from '@pura/harmony-utils';
import { BaseVM, CommonConstant } from 'base_common';

@ComponentV2
export struct CollapsibleCoordinator {
  @Param @Require vm: BaseVM;
  @BuilderParam @Require contentBuilder: (onScrollAction: (yOffset: number, scrollState: ScrollState) => void) => void;
  @BuilderParam @Require headerBuilder: () => void;
  // 默认参数配置
  @Param topSpace: number = CommonConstant.IconSizeLarge + CommonConstant.NormalContainerInnerPadding;
  @Param headerHeight: number = CommonConstant.IconSizeLarge + CommonConstant.SmallContainerInnerPadding * 2 +
    CommonConstant.BorderSizeNormal * 2 + CommonConstant.NormalContainerInnerPadding;
  @Param headerCoreHeight: number = CommonConstant.IconSizeLarge + CommonConstant.SmallContainerInnerPadding * 2 +
    CommonConstant.BorderSizeNormal * 2;
  @Consumer("isHideNavTitle") isHideNavTitle: boolean = false;
  @Consumer("isHideTabBar") isHideTabBar: boolean = false;

  @Computed
  get initialTopSpaceHeight(): number {
    return CommonConstant.TopBarHeight + this.vm.window.windowTopPadding + this.topSpace;
  }

  @Computed
  get initialContentPaddingTop(): number {
    return this.initialTopSpaceHeight + this.headerHeight;
  }

  @Computed
  get collapsedTopSpaceHeight(): number {
    return this.vm.window.windowTopPadding +
      (CommonConstant.TopBarHeight - this.headerCoreHeight) / 2;
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
            .height(this.initialContentPaddingTop)
        }

        this.contentBuilder((y, s) => {
          this.handleScroll(y, s);
        });
      }
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)

      // --- 顶层：吸顶 Header 区域 ---
      Column() {
        if (!this.isHideNavTitle) {
          Column()
            .height(this.initialTopSpaceHeight)
        } else {
          Column()
            .height(this.collapsedTopSpaceHeight)
        }

        Row() {
          this.headerBuilder();
        }
        .zIndex(999)
      }
      .width(CommonConstant.FullPercent)
      .hitTestBehavior(HitTestMode.Transparent)
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
  }
}