import { CommonConstant } from 'base_common';
import { MinePageVM } from '../viewmodels/MinePageVM';
import { StickyNavBar } from './StickyNavBar';
import { UserInfoArea } from './UserInfoArea';
import { UserPostArea } from './UserPostArea';

@ComponentV2
export struct UserProfileView {
  @Param @Require vm: MinePageVM;
  // 用于测量 UserInfoArea 的高度，确定吸顶阈值
  @Local userInfoHeight: number = 200;

  build() {
    Stack({ alignContent: Alignment.Top }) {
      // 背景层
      Image("https://gips2.baidu.com/it/u=2055042668,1190219470&fm=3028&app=3028&f=JPEG&fmt=auto?w=960&h=1280")
        .width(CommonConstant.FullPercent)
        .height(CommonConstant.FullPercent)
        .objectFit(ImageFit.Cover)
        .opacity(0.5)
        .blur(40)
        .fillColor($r('app.color.glass_background'))

      Refresh({ refreshing: this.vm.isRefreshing }) {
        Scroll(this.vm.outerScrollScroller) {
          Column({ space: CommonConstant.NormalContainerInnerPadding }) {
            UserInfoArea({ vm: this.vm })
              .onAreaChange((oldValue, newValue) => {
                if (typeof newValue.height === 'number') {
                  this.userInfoHeight = newValue.height;
                }
              })

            UserPostArea({ vm: this.vm })
              .height(this.vm.window.windowHeight - CommonConstant.TopBarHeight - this.vm.window.windowTopPadding)
              .width(CommonConstant.FullPercent)
          }
          .width(CommonConstant.FullPercent)
        }
        .scrollBar(BarState.Off)
        .width(CommonConstant.FullPercent)
        .height(CommonConstant.FullPercent)
        .onScroll(() => {
          const yOffset = this.vm.outerScrollScroller.currentOffset().yOffset;

          // 计算 StickyNavBar 的不透明度
          const threshold = this.userInfoHeight / 2;
          this.vm.navBarOpacity = Math.min(Math.max(yOffset / threshold, 0), 1);

          // 计算 TabBar 的 Glass 效果
          // 当滚动超过 userInfoHeight - TopBarHeight 时，Tab 栏接触顶部
          const glassThreshold = this.userInfoHeight - CommonConstant.TopBarHeight - this.vm.window.windowTopPadding;
          const isSticky = yOffset >= glassThreshold;

          if (this.vm.isTabBarGlass !== isSticky) {
            this.vm.isTabBarGlass = isSticky;
          }
        })
      }
      .onRefreshing(() => {
        this.vm.onRefreshAll();
      })

      StickyNavBar({ vm: this.vm })
        .opacity(this.vm.navBarOpacity)
        .hitTestBehavior(this.vm.navBarOpacity > 0.5 ? HitTestMode.Default : HitTestMode.None)
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
  }
}