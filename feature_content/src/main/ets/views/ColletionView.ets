import { Collection, CommonConstant, VMManager } from 'base_common';
import { CollapsibleCoordinator, CustomTabBar, FloatButton } from 'base_ui';
import { CollectionCard } from '../components/CollectionCard';
import { CollectionVM } from '../viewmodels/CollectionVM';

const TAG = '[CollectionView]: '

@ComponentV2
export struct CollectionView {
  @Local vm: CollectionVM = VMManager.get(CollectionVM, () => new CollectionVM());
  @Consumer("isHideNavTitle") isHideNavTitle: boolean = false;

  async aboutToAppear() {
    await this.vm.loadData();
  }

  @Builder
  contentBody(onScrollAction: (yOffset: number, scrollState: ScrollState) => void) {
    Refresh({ refreshing: $$this.vm.isRefreshing }) {
      WaterFlow() {
        ForEach(this.vm.collections, (collection: Collection) => {
          FlowItem() {
            CollectionCard({
              collection
            })
          }
          .width(CommonConstant.FullPercent)
        }, (collection: Collection) => `${collection.creator.uid}_${collection.title}`)
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
        this.vm.loadMore();
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
    .width(CommonConstant.FullPercent)
    .layoutWeight(1)
    .onRefreshing(() => {
      this.vm.refresh();
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
              tabItems: this.vm.sortTabItems,
              isMax: true,
              isGlassStyle: true,
              alignMode: this.vm.isTabletView ? FlexAlign.Start : FlexAlign.Center,
              currentIndex: this.vm.currentSortIndex,
              changeTab: (index: number) => {
                this.vm.changeSort(index);
              }
            })
          }
          .layoutWeight(1)
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