// feature_mine/src/main/ets/components/UserPostArea.ets
import { CommonConstant, ForumTieSummary, UiState } from 'base_common';
import { CustomTabBar, StateLayout } from 'base_ui';
import { MinePageVM } from '../viewmodels/MinePageVM';
import { TieCard } from './TieCard';

// 兼容接口：用于访问 ForumTieSummary 中可能不存在但 API 返回了的 forum_name
interface TieWithForumName {
  forum_name?: string;
}

/**
 * 独立的列表组件，确保在 Tabs 切换时能正确响应数据变化
 */
@ComponentV2
struct UserPostList {
  @Param @Require vm: MinePageVM;
  @Param @Require index: number;
  @Param @Require scroller: Scroller;

  // 动态获取当前 Tab 的状态
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

  // 动态获取当前 Tab 的数据
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

  // 渲染列表内容，包含 WaterFlow 和 TieCard
  @Builder
  renderList() {
    Refresh({ refreshing: this.isRefreshing }) {
      WaterFlow({ scroller: this.scroller }) {
        ForEach(this.currentData, (tie: ForumTieSummary) => {
          FlowItem() {
            TieCard({
              tie: tie,
              // 使用类型断言安全访问 forum_name
              forumName: tie.forum_name || ''
            })
            // 关键 1: 设置唯一 ID，用于一镜到底动画定位
              .id(tie.thread_id.toString())
              // 关键 2: 点击时传递 context 和 ID 给 VM
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
        // 处理吸顶效果
        const yOffset = this.scroller.currentOffset().yOffset;
        if (yOffset > 0 && !this.vm.isTabBarGlass) {
          this.vm.isTabBarGlass = true;
        } else if (yOffset <= 0 && this.vm.isTabBarGlass) {
          this.vm.isTabBarGlass = false;
        }
      })
    }
    .onRefreshing(() => {
      this.onRefresh();
    })
  }

  build() {
    StateLayout({
      uiState: this.currentState,
      onRetry: this.onRefresh,
      // 如果是收藏页且不是自己，显示空状态提示
      emptyStr: this.index === 2 && !this.vm.isMe ? $r('app.string.StateLayout_empty') : undefined,
      content: () => {
        this.renderList();
      }
    })
  }
}

@ComponentV2
export struct UserPostArea {
  @Param @Require vm: MinePageVM;
  // 为每个 Tab 维护一个独立的 Scroller
  private listScrollers: Scroller[] = [new Scroller(), new Scroller(), new Scroller()];

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Tabs({ index: this.vm.currentUserPostTabIndex, controller: this.vm.userPostTabController }) {
        // Tab 1: 发布的帖子
        TabContent() {
          UserPostList({
            vm: this.vm,
            index: 0,
            scroller: this.listScrollers[0],
            onLoadMore: async (): Promise<void> => this.vm.loadThreads(false),
            onRefresh: async (): Promise<void> => this.vm.loadThreads(true)
          })
        }

        // Tab 2: 回复的帖子
        TabContent() {
          UserPostList({
            vm: this.vm,
            index: 1,
            scroller: this.listScrollers[1],
            onLoadMore: async (): Promise<void> => this.vm.loadReplies(false),
            onRefresh: async (): Promise<void> => this.vm.loadReplies(true)
          })
        }

        // Tab 3: 收藏的帖子
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

      // 吸顶 TabBar
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
    // 关键 3: 绑定缩放动画属性
    .scale({
      x: this.vm.pageScale,
      y: this.vm.pageScale
    })
    .animation({ duration: CommonConstant.AnimationDurationNormal })
  }
}