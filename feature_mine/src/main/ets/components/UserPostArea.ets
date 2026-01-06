// feature_mine/src/main/ets/components/UserPostArea.ets
import { AppUtil } from '@pura/harmony-utils';
import { CommonConstant, ForumTieSummary } from 'base_common';
import { CustomTabBar, StateLayout } from 'base_ui';
import { MinePageVM, MineTabVM } from '../viewmodels/MinePageVM';
import { TieCard } from './TieCard';

interface TieWithForumName {
  forum_name?: string;
}

@ComponentV2
struct UserPostList {
  // 核心变更：接收 MineTabVM 而不是 PageVM
  @Param @Require vm: MineTabVM;
  @Param @Require scroller: Scroller;
  @Param isMe: boolean = false; // 用于判断是否显示收藏空文案
  // 记录捏合开始时的列数
  @Local baseColumns: number = 2;

  @Computed
  get columnsTemplate(): string {
    return '1fr '.repeat(this.vm.columns).trim();
  }

  @Computed
  get spacerArray(): number[] {
    return new Array(this.vm.columns).fill(0);
  }

  @Event onLoadMore: () => void = () => {
  };
  @Event onRefresh: () => void = () => {
  };

  @Builder
  renderList() {
    Refresh({ refreshing: this.vm.isRefreshing }) {
      WaterFlow({ scroller: this.scroller }) {
        ForEach(this.spacerArray, (_: number, i: number) => {
          FlowItem() {
            Column().height(CommonConstant.IconSizeLarge)
          }
          .width(CommonConstant.FullPercent)
        }, (_: number, i: number) => `top_spacer_${this.vm.columns}_${i}`)

        // === 2. 数据列表 ===
        ForEach(this.vm.list, (tie: ForumTieSummary) => {
          FlowItem() {
            TieCard({
              tie: tie,
              forumName: tie.forum_name || ''
            })
              .id(this.vm.getUniqueId(tie.thread_id))
              .onClick(() => {
                this.vm.enterDetailPage(tie.thread_id, this.getUIContext(), tie);
              })
          }
          .width(CommonConstant.FullPercent)
        }, (tie: ForumTieSummary) => this.vm.getUniqueId(tie.thread_id))

        ForEach(this.spacerArray, (_: number, i: number) => {
          FlowItem() {
            Column()
              .height(this.vm.isTabletView ? 0 : CommonConstant.BottomBarHeight + this.vm.window.windowBottomPadding)
          }
          .width(CommonConstant.FullPercent)
        }, (_: number, i: number) => `bottom_spacer_${this.vm.columns}_${i}`)
      }
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
      .columnsTemplate(this.columnsTemplate)
      .columnsGap(CommonConstant.NormalContainerInnerPadding)
      .rowsGap(CommonConstant.NormalContainerInnerPadding)
      .padding({
        left: CommonConstant.NormalContainerInnerPadding,
        right: CommonConstant.NormalContainerInnerPadding,
      })
      .scrollBar(BarState.Off)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
      .animation({
        duration: CommonConstant.AnimationDurationNormal,
        curve: CommonConstant.AnimationCurveSpring
      })
      .onReachEnd(() => {
        this.vm.loadMineData(false);
      })
      .priorityGesture(
        PinchGesture()
          .onActionStart(() => {
            this.vm.isScaling = true;
            this.baseColumns = this.vm.columns;
          })
          .onActionUpdate((event: GestureEvent) => {
            const scale = event.scale;
            let newCols = this.baseColumns;

            if (scale > 0) {
              newCols = Math.round(this.baseColumns / scale);
            }

            newCols = Math.max(this.vm.minColumns, Math.min(newCols, this.vm.maxColumns));

            if (newCols !== this.vm.columns) {
              AppUtil.getUIContext()
                .animateTo({
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
      this.vm.loadMineData(true);
    })
  }

  build() {
    StateLayout({
      uiState: this.vm.state,
      onRetry: async (): Promise<void> => this.vm.loadMineData(true),
      emptyStr: !this.isMe && this.vm.list.length === 0 ? $r('app.string.StateLayout_empty') : undefined,
      content: () => {
        this.renderList();
      }
    })
  }
}

@ComponentV2
export struct UserPostArea {
  @Param @Require vm: MinePageVM;
  private listScrollers: Scroller[] = [new Scroller(), new Scroller(), new Scroller()];

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Tabs({ index: this.vm.currentUserPostTabIndex, controller: this.vm.userPostTabController }) {
        // Tab 1: 发布的帖子
        TabContent() {
          UserPostList({
            vm: this.vm.threadVM,
            scroller: this.listScrollers[0],
            isMe: this.vm.isMe
          })
        }

        // Tab 2: 回复的帖子
        TabContent() {
          UserPostList({
            vm: this.vm.replyVM,
            scroller: this.listScrollers[1],
            isMe: this.vm.isMe
          })
        }

        // Tab 3: 收藏的帖子
        TabContent() {
          UserPostList({
            vm: this.vm.favVM,
            scroller: this.listScrollers[2],
            isMe: this.vm.isMe
          })
        }
      }
      .barHeight(0)
      .scrollable(true)
      .height(CommonConstant.FullPercent)
      .width(CommonConstant.FullPercent)
      .onChange((index: number) => {
        this.vm.changeUserPostTab(index);

        // 切换 Tab 时处理吸顶状态 (可选优化)
        // 可以在这里根据 scroller 位置同步 isTabBarGlass 状态
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
    // 关键：绑定当前激活 Tab VM 的 pageScale
    .scale({
      x: this.vm.currentTabVM.pageScale,
      y: this.vm.currentTabVM.pageScale
    })
    .animation({
      duration: CommonConstant.AnimationDurationNormal,
      curve: CommonConstant.AnimationCurveSpring
    })
  }
}