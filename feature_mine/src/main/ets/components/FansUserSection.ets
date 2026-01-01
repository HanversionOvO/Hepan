import { BreakpointType, CommonConstant, InterestingUser, RecentVisitor, UserFriends } from 'base_common';
import { FansPageVM } from '../viewmodels/FansPageVM';
import { FansUserItem, FansUserItemType } from './FansUserItem';

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

  private handleScroll(yOffset: number, scrollState: ScrollState) {
    if (scrollState === ScrollState.Scroll) {
      // 手指向上滑是正值
      if (yOffset > CommonConstant.ScrollAnimationThreshold) {
        this.vm.toggleHeader(true);
      } else if (yOffset < -CommonConstant.ScrollAnimationThreshold) {
        this.vm.toggleHeader(false);
      }
    }
  }

  build() {
    Refresh({
      refreshing: $$this.vm.isFansTabRefreshing
    }) {
      Grid(this.vm.fansTabScroller) {
        // 1. 关注列表顶部横向卡片
        if (this.isFollowList) {
          GridItem() {
            List({ space: CommonConstant.NormalContainerInnerPadding }) {
              ForEach(this.vm.recommendList, (recommendUser: InterestingUser) => {
                ListItem() {
                  FansUserItem({ recommendUser: recommendUser, type: FansUserItemType.CARD })
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
        if (this.isFollowList) {
          ForEach(this.vm.friendsList, (friend: UserFriends) => {
            GridItem() {
              FansUserItem({
                user: {
                  uid: friend.uid,
                  username: friend.username,
                  avatar: friend.avatar,
                  signature: friend.signature,
                  level: friend.level,
                  date: friend.last_visit
                }
              })
            }
          })
        } else {
          ForEach(this.vm.visitorsList, (visitor: RecentVisitor) => {
            GridItem() {
              FansUserItem({
                user: {
                  uid: visitor.uid,
                  username: visitor.username,
                  avatar: visitor.avatar,
                  date: visitor.dateline
                }
              })
            }
          })
        }

        // 3. 底部垫片
        GridItem()
          .height(this.vm.window.windowBottomPadding)
          .columnStart(0)
          .columnEnd(this.gridLanes - 1)
      }
      .columnsTemplate('1fr '.repeat(this.gridLanes)) // 使用 gridLanes
      .columnsGap(CommonConstant.NormalContainerInnerPadding)
      .rowsGap(CommonConstant.NormalContainerInnerPadding)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .onWillScroll((yOffset, scrollState) => {
        this.handleScroll(yOffset, scrollState);
      })
      .onReachStart(() => {
        this.vm.toggleHeader(false);
      })
      .onReachEnd(() => {
        this.vm.loadMore();
      })
    }
    .onRefreshing(async () => {
      this.vm.refreshFansPage();
    })
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
  }
}