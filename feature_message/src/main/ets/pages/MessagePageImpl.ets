import { CommonConstant, TransitionMap, VMManager } from 'base_common';
import { CustomNavTitle, CustomSearch } from 'base_ui';
import { MessageNotifyCard } from '../components/MessageNotifyCard';
import { MessagePageVM } from '../viewmodels/MessagePageVM';

@ComponentV2
export struct MessagePageImpl {
  @Local vm: MessagePageVM = VMManager.get(MessagePageVM, () => new MessagePageVM());
  @Local minNavBarWidth: number = 340;
  @Local gridLanes: number = 2;

  @Computed
  get defaultNavBarWidth(): number {
    return (this.vm.window.windowWidth - CommonConstant.BottomBarHeight) / 2;
  }

  @Builder
  build() {
    Navigation() {
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
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.start_window_background'))
    .mode(this.vm.isTabletView ? NavigationMode.Split : NavigationMode.Stack)
    .navBarWidthRange([this.minNavBarWidth, this.defaultNavBarWidth])
    .navBarWidth(this.defaultNavBarWidth)
  }
}