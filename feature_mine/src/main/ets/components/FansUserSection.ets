import { BreakpointType, CommonConstant } from 'base_common';
import { FansPageVM } from '../viewmodels/FansPageVM';

@ComponentV2
export struct FansUserSection {
  @Param @Require vm: FansPageVM;
  @Param isFollowList: boolean = false;
  @Local lanesOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 5,
  });

  @Computed
  get gridLanes(): number {
    return this.lanesOptions.getValue(this.vm.breakPoint.currentBreakPoint);
  }

  build() {
    Refresh({
      refreshing: $$this.vm.isFansTabRefreshing
    }) {
      Grid(this.vm.fansTabScroller) {
        // 1. 关注列表顶部横向卡片
        if (this.isFollowList) {
          GridItem() {
            List({ space: CommonConstant.SmallContainerInnerPadding }) {
              ForEach(this.vm.recommendList, (item: number) => {
                ListItem() {
                  // FansUserItem({ index: item, type: FansUserItemType.CARD })
                }
              })
            }
            .width(CommonConstant.FullPercent)
            .listDirection(Axis.Horizontal)
            .scrollBar(BarState.Off)
            .fadingEdge(true)
          }
          .columnStart(0)
          .columnEnd(this.gridLanes - 1) // 动态计算跨列
        }

        // 2. 列表主体
        ForEach(this.vm.friendsList, (item: number) => {
          GridItem() {
            // FansUserItem({ index: item, type: FansUserItemType.LIST })
          }
        })

        // 3. 底部垫片
        GridItem()
          .height(this.vm.window.windowBottomPadding)
          .columnStart(0)
          .columnEnd(this.gridLanes - 1)
      }
      .columnsTemplate('1fr '.repeat(this.gridLanes)) // 使用 gridLanes
      .columnsGap(CommonConstant.SmallContainerInnerPadding)
      .rowsGap(CommonConstant.SmallContainerInnerPadding)
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      // .onWillScroll((yOffset, scrollState) => {
      //   this.handleScroll(yOffset, scrollState);
      // })
      // .onReachStart(() => {
      //   this.toggleHeader(false);
      // })
    }
    .onRefreshing(() => {
      // this.vm.refreshSubs();
    })
  }
}