import { CommonConstant, VMManager } from 'base_common';
import { CustomNavTitle, CustomTabBar } from 'base_ui';
import { ContentPageVM } from '../viewmodels/ContentPageVM';
import { TieView } from '../views/TieView';

@ComponentV2
export struct ContentPageImpl {
  @Local vm: ContentPageVM = VMManager.get(ContentPageVM, () => new ContentPageVM())
  @Provider("isHideNavTitle") isHideNavTitle: boolean = false;
  @Provider("isHideTabBar") isHideTabBar: boolean = false;

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Column() {
          Tabs({ index: this.vm.currentIndex }) {
            TabContent() {
              TieView()
            }
          }
          .width(CommonConstant.FullPercent)
          .layoutWeight(1)
          .barHeight(0)
          .scrollable(false)
        }
        .width(CommonConstant.FullPercent)
        .layoutWeight(1)

        Column() {
          CustomNavTitle({
            vm: this.vm,
            title: $r('app.string.ContentPage_title'),
            buttons: this.vm.titleButtons,
            bgColor: Color.Transparent,
            enableGlassMode: this.isHideNavTitle ? true : false,
            isHideTitle: !this.vm.isTabletView && this.isHideNavTitle
          })
            .transition(TransitionEffect.move(TransitionEdge.START))

          if (!this.isHideTabBar) {
            CustomTabBar({
              vm: this.vm,
              tabItems: this.vm.contentPageTabItems,
              alignMode: this.vm.isTabletView ? FlexAlign.Start : FlexAlign.Center,
              currentIndex: this.vm.currentIndex,
              changeTab: (index: number) => {
                this.vm.changeTab(index)
              }
            })
              .padding({
                left: CommonConstant.PageLRPadding,
                right: CommonConstant.PageLRPadding
              })
              .transition(TransitionEffect.move(TransitionEdge.TOP)
                .combine(TransitionEffect.move(TransitionEdge.START)))
          }
        }
        .hitTestBehavior(HitTestMode.Transparent)
      }
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.start_window_background'))
  }
}