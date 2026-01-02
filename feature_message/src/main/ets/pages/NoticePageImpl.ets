import { AnPNotification, CommonConstant, RouterUtil, StackEnum } from 'base_common'
import { FloatButton, StateLayout } from 'base_ui'
import { MessageNotifyCardItem } from '../components/MessageNotifyCard'
import { NoticeCard } from '../components/NoticeCard'
import { NoticeNavBar } from '../components/NoticeNavBar'
import { NoticePageVM } from '../viewmodels/NoticePageVM'

const TAG = '[NoticePageImpl]: ';

@ComponentV2
export struct NoticePageImpl {
  @Local vm: NoticePageVM = new NoticePageVM();

  private handleScroll(yOffset: number, scrollState: ScrollState) {
    if (scrollState === ScrollState.Scroll) {
      if (yOffset > CommonConstant.ScrollAnimationThreshold) {
        this.vm.toggleHeader(true);
      } else if (yOffset < -CommonConstant.ScrollAnimationThreshold) {
        this.vm.toggleHeader(false);
      }
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Column({ space: CommonConstant.NormalContainerInnerPadding }) {
          if (!this.vm.isHideNavBar) {
            NoticeNavBar({
              vm: this.vm
            })
          }

          StateLayout({
            uiState: this.vm.uiState
          }) {
            Refresh({ refreshing: $$this.vm.isRefreshingNotice }) {
              Grid(new Scroller()) {
                ForEach(this.vm.messageCards, (messageCard: AnPNotification) => {
                  GridItem() {
                    NoticeCard({
                      vm: this.vm,
                      messageCard: messageCard
                    })
                  }
                }, (messageCard: AnPNotification) => messageCard.reply_remind_id.toString())

                GridItem()
                  .height(this.vm.isTabletView ?
                    this.vm.window.windowBottomPadding :
                    CommonConstant.BottomBarHeight + this.vm.window.windowBottomPadding +
                    CommonConstant.NormalContainerTBPadding)
              }
              .columnsTemplate('1fr')
              .rowsGap(CommonConstant.NormalContainerInnerPadding)
              .width(CommonConstant.FullPercent)
              .height(CommonConstant.FullPercent)
              .padding({
                left: CommonConstant.PageLRPadding,
                right: CommonConstant.PageLRPadding,
              })
              .scrollBar(BarState.Off)
              .edgeEffect(EdgeEffect.Spring)
              .onWillScroll((yOffset, scrollState) => {
                this.handleScroll(yOffset, scrollState);
              })
              .onReachStart(() => {
                this.vm.toggleHeader(false);
              })
              .onReachEnd(async () => {
                await this.vm.loadMore();
              })
            }
            .onRefreshing(async () => {
              await this.vm.refreshData();
            })
            .layoutWeight(1)
          }
        }

        FloatButton({ isFloating: this.vm.isHideNavBar, floatIconColor: $r('sys.color.font_on_primary') })
          .position({
            top: this.vm.window.windowTopPadding + (CommonConstant.TopBarHeight - CommonConstant.IconSizeLarge) / 2,
            left: CommonConstant.PageLRPadding
          })
          .onClick(() => {
            animateTo({ curve: CommonConstant.AnimationCurveSpring, duration: CommonConstant.AnimationDurationNormal },
              () => {
                RouterUtil.pop(undefined, false, StackEnum.MESSAGE);
              })
          })
          .zIndex(2)
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.start_window_background'))
    .onReady(async (context: NavDestinationContext) => {
      const params = context.pathInfo.param as MessageNotifyCardItem;
      if (params) {
        this.vm.messageNotifyCard = params;

        await this.vm.loadData();
      }
    })
  }
}