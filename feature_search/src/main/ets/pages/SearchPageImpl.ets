import { CommonConstant } from 'base_common';
import { CustomSearch, CustomTabBar, FloatButton } from 'base_ui';
import { SearchPageVM } from '../viewmodels/SearchPageVM';

@ComponentV2
export struct SearchPageImpl {
  @Local vm: SearchPageVM = new SearchPageVM();

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Column({ space: CommonConstant.NormalContainerInnerPadding }) {
          Column({ space: CommonConstant.NormalContainerInnerPadding }) {
            Row({ space: CommonConstant.NormalContainerInnerPadding }) {
              FloatButton({ isFloating: true })

              CustomSearch()
                .layoutWeight(1)
            }
            .width(CommonConstant.FullPercent)

            CustomTabBar({
              vm: this.vm,
              tabItems: this.vm.tabItems,
              alignMode: this.vm.isTabletView ? FlexAlign.Start : FlexAlign.Center
            })
          }
          .width(CommonConstant.FullPercent)
          .padding({
            top: CommonConstant.NormalContainerTBPadding + this.vm.window.windowTopPadding,
            left: CommonConstant.PageLRPadding,
            right: CommonConstant.PageLRPadding,
            bottom: CommonConstant.NormalContainerTBPadding
          })
          .backgroundColor($r('app.color.second_window_background'))
          .borderRadius({
            bottomLeft: CommonConstant.RadiusLarge,
            bottomRight: CommonConstant.RadiusLarge
          })
        }
        .width(CommonConstant.FullPercent)
        .layoutWeight(1)
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.start_window_background'))
    .onBackPressed(() => {
      this.vm.back();
      return true;
    })
  }
}