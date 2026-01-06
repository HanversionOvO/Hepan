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
  @Param @Require vm: MineTabVM;
  @Param @Require scroller: Scroller;
  @Param isMe: boolean = false;
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

  @Builder
  renderList() {
    WaterFlow({ scroller: this.scroller }) {
      ForEach(this.spacerArray, (_: number, i: number) => {
        FlowItem() {
          Column().height(CommonConstant.IconSizeLarge)
        }
        .width(CommonConstant.FullPercent)
      }, (_: number, i: number) => `top_spacer_${this.vm.columns}_${i}`)

      // 2. 数据列表
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

      // 3. 底部占位符 (仅手机)
      ForEach(this.spacerArray, (_: number, i: number) => {
        FlowItem() {
          Column()
            .height(CommonConstant.BottomBarHeight + this.vm.window.windowBottomPadding)
        }
        .width(CommonConstant.FullPercent)
      }, (_: number, i: number) => `bottom_spacer_${this.vm.columns}_${i}`)
    }
    .padding({
      left: CommonConstant.PageLRPadding,
      right: CommonConstant.PageLRPadding
    })
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
    .columnsTemplate(this.columnsTemplate)
    .columnsGap(CommonConstant.NormalContainerInnerPadding)
    .rowsGap(CommonConstant.NormalContainerInnerPadding)
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
        .onActionUpdate((event: GestureEvent) => {
          if (this.vm.isScaling) {
            return;
          }
          if (event.scale < 0.75 && this.vm.columns < this.vm.maxColumns) {
            AppUtil.getUIContext().animateTo({
              duration: CommonConstant.AnimationDurationNormal,
              curve: CommonConstant.AnimationCurveSpring
            }, () => {
              this.vm.columns += 1;
            });
            this.vm.isScaling = true;
          }

          if (event.scale > 1.25 && this.vm.columns > this.vm.minColumns) {
            animateTo({
              duration: CommonConstant.AnimationDurationNormal,
              curve: CommonConstant.AnimationCurveSpring
            }, () => {
              this.vm.columns -= 1;
            });
            this.vm.isScaling = true;
          }
        })
        .onActionEnd(() => {
          this.vm.isScaling = false;
        })
    )
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
        TabContent() {
          UserPostList({
            vm: this.vm.threadVM,
            scroller: this.listScrollers[0],
            isMe: this.vm.isMe
          })
        }

        TabContent() {
          UserPostList({
            vm: this.vm.replyVM,
            scroller: this.listScrollers[1],
            isMe: this.vm.isMe
          })
        }

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
        .padding({
          left: CommonConstant.PageLRPadding,
          right: CommonConstant.PageLRPadding
        })
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
    .backgroundColor($r('app.color.start_window_background'))
    .padding({
      top: CommonConstant.NormalContainerTBPadding,
    })
    .borderRadius({
      topLeft: this.vm.isTabBarGlass ? 0 : CommonConstant.RadiusUltraLarge,
      topRight: this.vm.isTabBarGlass ? 0 : CommonConstant.RadiusUltraLarge,
    })
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