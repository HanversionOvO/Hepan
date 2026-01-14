import { Collection, CommonConstant } from 'base_common';
import { CollapsibleCoordinator, CollectionCard, CustomTabBar, FloatButton } from 'base_ui';
import { collectionCreateSheetBuilder } from '../components/CollectionCreateSheet';
import { CollectionVM } from '../viewmodels/CollectionVM';

const TAG = '[CollectionView]: '

@ComponentV2
export struct CollectionView {
  @Local vm: CollectionVM = new CollectionVM();
  @Consumer("isHideNavTitle") isHideNavTitle: boolean = false;

  async aboutToAppear() {
    await this.vm.loadData();
  }

  @Builder
  contentBody(onScrollAction: (yOffset: number, scrollState: ScrollState, isAtTop?: boolean) => void) {
    Refresh({ refreshing: $$this.vm.isRefreshing }) {
      WaterFlow() {
        FlowItem() {
          Column({ space: CommonConstant.SmallContainerInnerPadding }) {
            SymbolGlyph($r('sys.symbol.plus'))
              .fontSize(CommonConstant.IconSizeLarge)
              .fontColor([CommonConstant.ThemeColor])
              .fontWeight(FontWeight.Bold)

            Text($r('app.string.CollectionPage_create_collection'))
              .fontSize(CommonConstant.TextSizeSmall)
              .fontColor(CommonConstant.ThemeColor)
              .fontWeight(FontWeight.Bold)
          }
          .width(CommonConstant.FullPercent)
          .padding(CommonConstant.NormalContainerInnerPadding)
          .border(
            {
              width: CommonConstant.BorderSizeLarge,
              color: CommonConstant.ThemeColor,
              style: BorderStyle.Dashed
            }
          )
          .borderRadius(CommonConstant.RadiusLarge)
          .backgroundColor($r('app.color.second_window_background'))
          .onClick(() => {
            this.vm.isShowCollectionCreateSheet = true;
          })
          .animation({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.85 })
          .bindSheet($$this.vm.isShowCollectionCreateSheet, collectionCreateSheetBuilder(this.vm), {
            showClose: true,
            detents: [SheetSize.FIT_CONTENT],
            enableOutsideInteractive: false,
            preferType: this.vm.isTabletView ? SheetType.CENTER : SheetType.BOTTOM,
            backgroundColor: $r('app.color.start_window_background'),
            blurStyle: BlurStyle.BACKGROUND_ULTRA_THICK,
            title: {
              title: $r('app.string.CollectionPage_create_collection')
            }
          })
        }
        .width(CommonConstant.FullPercent)

        ForEach(this.vm.collections, (collection: Collection) => {
          FlowItem() {
            CollectionCard({
              collection
            })
              .id(collection.ctid.toString())
              .onClick(() => {
                this.vm.enterDetailPage(collection.ctid.toString(), this.getUIContext(), collection);
              })
          }
          .width(CommonConstant.FullPercent)
        }, (collection: Collection) => collection.ctid.toString())
      }
      .width(CommonConstant.FullPercent)
      .layoutWeight(1)
      .columnsTemplate('1fr '.repeat(this.vm.columns)
        .trim())
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
      .onReachStart(() => {
        onScrollAction(0, ScrollState.Idle, true);
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
      .scale({
        x: this.vm.pageScale,
        y: this.vm.pageScale,
      })
  }
}
