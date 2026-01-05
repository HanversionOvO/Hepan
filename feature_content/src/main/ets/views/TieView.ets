import { CommonConstant, ForumTieSummary, VMManager } from 'base_common';
import {
  CollapsibleCoordinator, CustomTabBar, FloatButton
} from 'base_ui';
import { SortButton } from '../components/SortButton';
import { SubCategoryButton } from '../components/SubCategoryButton';
import { SubCategoryPanel } from '../components/SubCategoryPanel';
import { TieCard } from '../components/TieCard';
import { TieVM } from '../viewmodels/TieVM';

const TAG = '[TieView]: ';

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

    Refresh({ refreshing: $$this.vm.isRefreshTie }) {
      WaterFlow() {
        ForEach(this.vm.ties, (tie: ForumTieSummary) => {
          FlowItem() {
            TieCard({
              tie: tie,
              forumName: this.vm.getForumName(tie.forum_id)
            })
              .id(tie.thread_id.toString())
              .onClick(() => {
                this.vm.enterDetailPage(tie.thread_id.toString(), this.getUIContext(), tie);
              })
          }
          .width(CommonConstant.FullPercent)
        }, (tie: ForumTieSummary) => tie.thread_id.toString())
      }
      .width(CommonConstant.FullPercent)
      .layoutWeight(1)
      .columnsTemplate('1fr '.repeat(this.vm.columns).trim())
      .columnsGap(CommonConstant.NormalContainerInnerPadding)
      .rowsGap(CommonConstant.NormalContainerInnerPadding)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .onWillScroll((yOffset, scrollState) => {
        onScrollAction(yOffset, scrollState);
      })
      .onReachEnd(() => {
        this.vm.loadNextPage();
      })
      .priorityGesture(
        PinchGesture()
          .onActionUpdate((event: GestureEvent) => {
            if (this.vm.isScaling) {
              return;
            }
            if (event.scale < 0.75 && this.vm.columns < this.vm.maxColumns) {
              animateTo({
                duration: CommonConstant.AnimationDurationNormal,
                curve: CommonConstant.AnimationCurveSpring
              }, () => {
                this.vm.columns += 1;
              });
              this.vm.isScaling = true;
            }

            if (event.scale > 1.25 && this.vm.columns > this.vm.minColumns) {
              animateTo({
                duration: CommonConstant.AnimationDurationNormal,
                curve: CommonConstant.AnimationCurveSpring
              }, () => {
                this.vm.columns -= 1;
              });
              this.vm.isScaling = true;
            }
          })
          .onActionEnd(() => {
            this.vm.isScaling = false;
          })
      )
    }
    .onRefreshing(() => {
      this.vm.loadTies(true);
    })
    .width(CommonConstant.FullPercent)
    .layoutWeight(1)
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
      .scale({
        x: this.vm.pageScale,
        y: this.vm.pageScale,
      })
  }
}