import { CommonConstant } from 'base_common';
import { CustomSearch, CustomTabBar, FloatButton } from 'base_ui';
import { SearchPageVM, SearchStatus } from '../viewmodels/SearchPageVM';
import { QueryView } from '../views/QueryView';
import { ResultView } from '../views/ResultView';
import { ReviewView } from '../views/ReviewView';

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
                .onClick(() => {
                  this.vm.back();
                })

              CustomSearch({
                text: this.vm.keyword,
                onChange: (value: string) => {
                  this.vm.onSearchInputChange(value);
                },
                onSubmit: (value: string) => {
                  this.vm.onSearchSubmit(value);
                }
              })
                .layoutWeight(1)
            }
            .width(CommonConstant.FullPercent)

            CustomTabBar({
              vm: this.vm,
              tabItems: this.vm.tabItems,
              alignMode: this.vm.isTabletView ? FlexAlign.Start : FlexAlign.Center,
              currentIndex: this.vm.currentSearchIndex,
              changeTab: (index: number) => {
                this.vm.changeTab(index);
              }
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

          Column() {
            if (this.vm.searchStatus === SearchStatus.QUERY) {
              QueryView()
            } else if (this.vm.searchStatus === SearchStatus.REVIEW) {
              ReviewView({ vm: this.vm })
            } else if (this.vm.searchStatus === SearchStatus.RESULT) {
              ResultView({ vm: this.vm })
            }
          }
          .width(CommonConstant.FullPercent)
          .layoutWeight(1)
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
    .onReady((navDestContext: NavDestinationContext) => {
      let params = navDestContext.pathInfo?.param as Record<string, Object>;
      if (params) {
        if (params["searchType"]) {
          if (params["searchType"] === "user") {
            this.vm.currentSearchIndex = 1;
          }
        }
      }
    })
  }
}