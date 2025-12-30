import { CommonConstant } from 'base_common';
import { CustomTabBar } from 'base_ui';
import { MinePageVM } from '../viewmodels/MinePageVM';

@ComponentV2
export struct UserPostArea {
  @Param @Require vm: MinePageVM;

  @Builder
  TabsInternal(index: number) {
    List() {
      ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], (i: number) => {
        ListItem() {
          Text(`Content ${index} - Item ${i}`)
        }
        .height(100)
        .backgroundColor('#f5f5f5')
        .borderRadius(8)
        .margin(5)
      })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 12, right: 12 })
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Tabs({ index: this.vm.currentUserPostTabIndex, controller: this.vm.userPostTabController }) {
        TabContent() {
          this.TabsInternal(1)
        }

        TabContent() {
          this.TabsInternal(2)
        }

        TabContent() {
          this.TabsInternal(3)
        }
      }
      .barHeight(0)
      .scrollable(false)
      .height(CommonConstant.FullPercent)
      .width(CommonConstant.FullPercent)

      CustomTabBar({
        vm: this.vm,
        tabItems: this.vm.userPostTabItems,
        currentIndex: this.vm.currentUserPostTabIndex,
        changeTab: (index: number) => {
          this.vm.changeUserPostTab(index);
        },
        alignMode: this.vm.isTabletView ? FlexAlign.Start : FlexAlign.Center
      })
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
    .constraintSize({ maxHeight: this.vm.window.windowHeight - CommonConstant.TopBarHeight })
    .backgroundColor($r('app.color.start_window_background'))
    .padding({
      left: CommonConstant.NormalContainerLRPadding,
      right: CommonConstant.NormalContainerLRPadding,
      top: CommonConstant.NormalContainerTBPadding,
    })
    .borderRadius({
      topLeft: CommonConstant.RadiusNormal,
      topRight: CommonConstant.RadiusNormal
    })
  }
}