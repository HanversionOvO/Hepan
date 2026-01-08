import { LogUtil } from '@pura/harmony-utils';
import { CollectionApi, CollectionSortOrder, CommonConstant, VMManager } from 'base_common';
import { CollapsibleCoordinator, CustomTabBar, FloatButton } from 'base_ui';
import { CollectionVM } from '../viewmodels/CollectionVM';

const TAG = '[CollectionView]: '

@ComponentV2
export struct CollectionView {
  @Local vm: CollectionVM = VMManager.get(CollectionVM, () => new CollectionVM());
  @Consumer("isHideNavTitle") isHideNavTitle: boolean = false;

  async aboutToAppear() {
    const result = await CollectionApi.getCollections(1, CollectionSortOrder.THREAD_NUM);
    LogUtil.debug(TAG, JSON.stringify(result));
  }

  @Builder
  contentBody() {
    Refresh({ refreshing: $$this.vm.isRefreshing })
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
              tabItems: this.vm.sortTabItems,
              isMax: true,
              isGlassStyle: true,
              alignMode: this.vm.isTabletView ? FlexAlign.Start : FlexAlign.Center,
              currentIndex: this.vm.currentSort,
              changeTab: (index: number) => {

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