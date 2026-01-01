import { CommonConstant, VMManager } from 'base_common';
import { StickyNavBar } from '../components/StickyNavBar';
import { UserInfoArea } from '../components/UserInfoArea';
import { UserPostArea } from '../components/UserPostArea';
import { MinePageVM } from '../viewmodels/MinePageVM';

@ComponentV2
export struct MinePageImpl {
  @Local vm: MinePageVM = VMManager.get(MinePageVM, () => new MinePageVM())

  aboutToAppear(): void {
    this.vm.startMine();
  }

  build() {
    Navigation() {
      Stack({ alignContent: Alignment.Top }) {
        Column()
          .width(CommonConstant.FullPercent)
          .height(CommonConstant.FullPercent)
          .backgroundColor(Color.Black)
          .opacity(0.2)

        Scroll(this.vm.outerScrollScroller) {
          Column() {
            UserInfoArea({ vm: this.vm })
              .padding({
                left: CommonConstant.NormalContainerLRPadding,
                right: CommonConstant.NormalContainerLRPadding,
                top: CommonConstant.NormalContainerTBPadding,
                bottom: CommonConstant.NormalContainerTBPadding
              })

            UserPostArea({ vm: this.vm })
          }
        }
        .scrollBar(BarState.Off)
        .height(CommonConstant.FullPercent)
        .onReachEnd(() => {
          if (!this.vm.isSticky) {
            this.vm.isSticky = true;
          }
        })
        .onDidScroll(() => {
          const isAtEnd = this.vm.outerScrollScroller.isAtEnd();
          if (this.vm.isSticky && !isAtEnd) {
            this.vm.isSticky = false;
          }
          if (!this.vm.isSticky && isAtEnd) {
            this.vm.isSticky = true;
          }
        })

        if (this.vm.isSticky) {
          StickyNavBar({ vm: this.vm })
        }
      }
      .backgroundImage("https://gips2.baidu.com/it/u=2055042668,1190219470&fm=3028&app=3028&f=JPEG&fmt=auto?w=960&h=1280")
      .backgroundImageSize(ImageSize.Cover)
      .backgroundImagePosition(Alignment.Center)
      .backgroundBlurStyle(BlurStyle.Regular)
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
      .transition(CommonConstant.CONF_TRANSITION)
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .backgroundColor($r('app.color.start_window_background'))
  }
}