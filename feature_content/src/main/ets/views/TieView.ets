import { CommonConstant, VMManager } from 'base_common';
import { CollapsibleCoordinator, CustomTabBar, FloatButton } from 'base_ui';
import { SortButton } from '../components/SortButton';
import { SubCategoryButton } from '../components/SubCategoryButton';
import { SubCategoryPanel } from '../components/SubCategoryPanel';
import { TieVM } from '../viewmodels/TieVM';

@ComponentV2
export struct TieView {
  @Local vm: TieVM = VMManager.get(TieVM, () => new TieVM())
  @Consumer("isHideNavTitle") isHideNavTitle: boolean = false;

  async aboutToAppear() {
    await this.vm.loadData();
  }

  @Builder
  contentBody(onScrollAction: (yOffset: number, scrollState: ScrollState) => void) {
    if (this.vm.isSubCategoryExpanded && !this.isHideNavTitle) {
      Column()
        .height(CommonConstant.IconSizeLarge + CommonConstant.SmallContainerTBPadding +
        CommonConstant.NormalContainerInnerPadding)
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
      onScrollAction(scrollOffset, scrollState);
    })
  }

  @Builder
  headerBody() {
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

      Column({ space: CommonConstant.NormalContainerInnerPadding }) {
        Row({ space: CommonConstant.NormalContainerInnerPadding }) {
          Row() {
            CustomTabBar({
              vm: this.vm,
              tabItems: this.vm.categoryTabItems,
              isMax: true,
              isGlassStyle: true,
              alignMode: this.vm.isTabletView ? FlexAlign.Start : FlexAlign.Center,
              currentIndex: this.vm.currentCategory,
              changeTab: (index: number) => {
                this.vm.changeCategory(index)
              }
            })
          }
          .layoutWeight(1)

          if (!this.vm.isSubCategoryExpanded) {
            SubCategoryButton({ vm: this.vm })
          }

          SortButton({ vm: this.vm })
        }

        if (this.vm.isSubCategoryExpanded) {
          SubCategoryPanel({ vm: this.vm })
        }
      }
      .layoutWeight(1)

      if (this.isHideNavTitle) {
        FloatButton()
          .opacity(0)
          .hitTestBehavior(HitTestMode.Transparent)
      }
    }
  }

  build() {
    CollapsibleCoordinator({
      vm: this.vm,
      contentBuilder: this.contentBody,
      headerBuilder: this.headerBody
    })
      .padding({
        left: CommonConstant.PageLRPadding,
        right: CommonConstant.PageLRPadding
      })
  }
}