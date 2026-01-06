import { AppUtil } from '@pura/harmony-utils';
import { CommonConstant, ForumTieSummary, UiState } from 'base_common';
import { CustomTabBar, StateLayout } from 'base_ui';
import { MinePageVM } from '../viewmodels/MinePageVM';
import { TieCard } from './TieCard';

interface TieWithForumName {
  forum_name?: string;
}

@ComponentV2
struct UserPostList {
  @Param @Require vm: MinePageVM;
  @Param @Require index: number;
  @Param @Require scroller: Scroller;
  // 记录捏合开始时的列数
  @Local baseColumns: number = 2;

  @Computed
  get currentState(): UiState {
    if (this.index === 0) {
      return this.vm.threadsState;
    }
    if (this.index === 1) {
      return this.vm.repliesState;
    }
    return this.vm.favoritesState;
  }

  @Computed
  get currentData(): ForumTieSummary[] {
    if (this.index === 0) {
      return this.vm.threads;
    }
    if (this.index === 1) {
      return this.vm.replies;
    }
    return this.vm.favorites;
  }

  @Computed
  get isRefreshing(): boolean {
    if (this.index === 0) {
      return this.vm.isRefreshingThreads;
    }
    if (this.index === 1) {
      return this.vm.isRefreshingReplies;
    }
    return this.vm.isRefreshingFavorites;
  }

  @Computed
  get columnsTemplate(): string {
    return '1fr '.repeat(this.vm.columns).trim();
  }

  @Event onLoadMore: () => void = () => {
  };
  @Event onRefresh: () => void = () => {
  };

  @Builder
  renderList() {
    Refresh({ refreshing: this.isRefreshing }) {
      WaterFlow({ scroller: this.scroller }) {
        ForEach(this.currentData, (tie: ForumTieSummary) => {
          FlowItem() {
            TieCard({
              tie: tie,
              forumName: tie.forum_name || ''
            })
              .id(tie.thread_id.toString())
              .onClick(() => {
                this.vm.enterDetailPage(tie.thread_id.toString(), this.getUIContext(), tie);
              })
          }
          .width(CommonConstant.FullPercent)
        }, (tie: ForumTieSummary) => `${this.index}_${tie.thread_id}_${tie.dateline}`)
      }
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
      .columnsTemplate(this.columnsTemplate)
      .columnsGap(CommonConstant.NormalContainerInnerPadding)
      .rowsGap(CommonConstant.NormalContainerInnerPadding)
      .padding({
        left: CommonConstant.NormalContainerInnerPadding,
        right: CommonConstant.NormalContainerInnerPadding,
        bottom: CommonConstant.NormalContainerInnerPadding
      })
      .scrollBar(BarState.Off)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
      .onReachEnd(() => {
        this.onLoadMore();
      })
      .onDidScroll(() => {
        const yOffset = this.scroller.currentOffset().yOffset;
        if (yOffset > 0 && !this.vm.isTabBarGlass) {
          this.vm.isTabBarGlass = true;
        } else if (yOffset <= 0 && this.vm.isTabBarGlass) {
          this.vm.isTabBarGlass = false;
        }
      })
      // === 新增：捏合手势 ===
      .priorityGesture(
        PinchGesture()
          .onActionStart(() => {
            this.vm.isScaling = true;
            this.baseColumns = this.vm.columns;
          })
          .onActionUpdate((event: GestureEvent) => {
            const scale = event.scale;
            let newCols = this.baseColumns;

            // 计算新列数：放大(scale>1)则列数减少，缩小(scale<1)则列数增加
            if (scale > 0) {
              newCols = Math.round(this.baseColumns / scale);
            }

            // 限制范围
            newCols = Math.max(this.vm.minColumns, Math.min(newCols, this.vm.maxColumns));

            if (newCols !== this.vm.columns) {
              AppUtil.getUIContext().animateTo({
                duration: CommonConstant.AnimationDurationNormal,
                curve: CommonConstant.AnimationCurveSpring
              }, () => {
                this.vm.columns = newCols;
              });
            }
          })
          .onActionEnd(() => {
            this.vm.isScaling = false;
          })
      )
    }
    .onRefreshing(() => {
      this.onRefresh();
    })
  }

  build() {
    StateLayout({
      uiState: this.currentState,
      onRetry: this.onRefresh,
      emptyStr: this.index === 2 && !this.vm.isMe ? $r('app.string.StateLayout_empty') : undefined,
      content: () => {
        this.renderList();
      }
    })
  }
}

// UserPostArea 组件保持不变，只需引用更新后的 UserPostList
@ComponentV2
export struct UserPostArea {
  @Param @Require vm: MinePageVM;
  private listScrollers: Scroller[] = [new Scroller(), new Scroller(), new Scroller()];

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Tabs({ index: this.vm.currentUserPostTabIndex, controller: this.vm.userPostTabController }) {
        TabContent() {
          UserPostList({
            vm: this.vm,
            index: 0,
            scroller: this.listScrollers[0],
            onLoadMore: async (): Promise<void> => this.vm.loadThreads(false),
            onRefresh: async (): Promise<void> => this.vm.loadThreads(true)
          })
        }

        TabContent() {
          UserPostList({
            vm: this.vm,
            index: 1,
            scroller: this.listScrollers[1],
            onLoadMore: async (): Promise<void> => this.vm.loadReplies(false),
            onRefresh: async (): Promise<void> => this.vm.loadReplies(true)
          })
        }

        TabContent() {
          UserPostList({
            vm: this.vm,
            index: 2,
            scroller: this.listScrollers[2],
            onLoadMore: async (): Promise<void> => this.vm.loadFavorites(false),
            onRefresh: async (): Promise<void> => this.vm.loadFavorites(true)
          })
        }
      }
      .barHeight(0)
      .scrollable(true)
      .height(CommonConstant.FullPercent)
      .width(CommonConstant.FullPercent)
      .onChange((index: number) => {
        this.vm.changeUserPostTab(index);
      })

      CustomTabBar({
        vm: this.vm,
        tabItems: this.vm.userPostTabItems,
        currentIndex: this.vm.currentUserPostTabIndex,
        changeTab: (index: number) => {
          this.vm.changeUserPostTab(index);
        },
        alignMode: this.vm.isTabletView ? FlexAlign.Start : FlexAlign.Center,
        isGlassStyle: this.vm.isTabBarGlass,
        isMax: this.vm.isTabletView
      })
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
    .constraintSize({
      maxHeight: this.vm.window.windowHeight -
      CommonConstant.TopBarHeight -
      this.vm.window.windowTopPadding
    })
    .backgroundColor($r('app.color.start_window_background'))
    .padding({
      left: CommonConstant.NormalContainerLRPadding,
      right: CommonConstant.NormalContainerLRPadding,
      top: CommonConstant.NormalContainerTBPadding,
    })
    .borderRadius({
      topLeft: this.vm.isSticky ? 0 : CommonConstant.RadiusUltraLarge,
      topRight: this.vm.isSticky ? 0 : CommonConstant.RadiusUltraLarge,
    })
    .scale({
      x: this.vm.pageScale,
      y: this.vm.pageScale
    })
    .animation({ duration: CommonConstant.AnimationDurationNormal })
  }
}