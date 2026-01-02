import { CommonConstant, RecentMessage, TransitionMap, VMManager } from 'base_common';
import { CustomNavTitle, CustomSearch } from 'base_ui';
import { MessageCard } from '../components/MessageCard';
import { MessageNotifyCard } from '../components/MessageNotifyCard';
import { MessagePageVM } from '../viewmodels/MessagePageVM';

@ComponentV2
export struct MessagePageImpl {
  @Local vm: MessagePageVM = VMManager.get(MessagePageVM, () => new MessagePageVM());
  @Local minNavBarWidth: number = 340;
  @Local gridLanes: number = 2;

  async aboutToAppear() {
    await this.vm.startMessage();
  }

  @Computed
  get defaultNavBarWidth(): number {
    return (this.vm.window.windowWidth - CommonConstant.BottomBarHeight) / 2;
  }

  private calcGridLanes(width: number): number {
    if (width < 450) {
      return 1;
    } else if (width < 840) {
      return 2;
    } else {
      return 3;
    }
  }

  @Builder
  build() {
    Navigation(this.vm.messageStack) {
      Stack({ alignContent: Alignment.Top }) {
        Column() {
          CustomNavTitle({
            vm: this.vm,
            title: $r('app.string.MessagePage_title'),
            buttons: this.vm.titleButtons
          })

          Column({ space: CommonConstant.NormalContainerInnerPadding }) {
            if (!this.vm.isHideSearch) {
              CustomSearch({ geometryId: TransitionMap.MessagePageSearch })
            }

            Refresh({ refreshing: $$this.vm.isRefreshingMessage }) {
              Grid(this.vm.messagePageScroller) {
                GridItem() {
                  MessageNotifyCard({
                    vm: this.vm
                  })
                }
                .columnStart(0)
                .columnEnd(this.gridLanes - 1)

                ForEach(this.vm.messages, (message: RecentMessage) => {
                  GridItem() {
                    MessageCard({
                      vm: this.vm,
                      message: message
                    })
                  }
                }, (item: RecentMessage) => item.plid.toString())

                GridItem()
                  .height(this.vm.isTabletView ?
                    this.vm.window.windowBottomPadding :
                    CommonConstant.BottomBarHeight + this.vm.window.windowBottomPadding +
                    CommonConstant.NormalContainerTBPadding)
                  .columnStart(0)
                  .columnEnd(this.gridLanes - 1)
              }
              .columnsTemplate('1fr '.repeat(this.gridLanes))
              .columnsGap(CommonConstant.NormalContainerInnerPadding)
              .rowsGap(CommonConstant.NormalContainerInnerPadding)
              .width(CommonConstant.FullPercent)
              .height(CommonConstant.FullPercent)
              .scrollBar(BarState.Off)
              .edgeEffect(EdgeEffect.Spring)
            }
            .layoutWeight(1)
          }
          .padding({
            left: CommonConstant.PageLRPadding,
            right: CommonConstant.PageLRPadding
          })
        }
        .width(CommonConstant.FullPercent)
        .height(CommonConstant.FullPercent)
        .onAreaChange((_oldVal, newVal) => {
          const newWidth = newVal.width as number;

          const newLanes = this.calcGridLanes(newWidth);
          if (this.gridLanes !== newLanes) {
            animateTo({
              duration: CommonConstant.AnimationDurationNormal,
              curve: CommonConstant.AnimationCurveNormal
            }, () => {
              this.gridLanes = newLanes;
            })
          }
        })
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.start_window_background'))
    .mode(this.vm.isTabletView ? NavigationMode.Split : NavigationMode.Stack)
    .navBarWidthRange([this.minNavBarWidth, this.defaultNavBarWidth])
    .navBarWidth(this.defaultNavBarWidth)
  }
}