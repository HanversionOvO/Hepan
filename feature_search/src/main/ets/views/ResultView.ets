import {
  CommonConstant, ForumTieSummary, SearchUser, UserAvatarUtil
} from 'base_common';
import { StateLayout } from 'base_ui';
import { SearchPageVM } from '../viewmodels/SearchPageVM';
import { TieCard } from 'feature_content/src/main/ets/components/TieCard';

@ComponentV2
export struct ResultView {
  @Param @Require vm: SearchPageVM;

  build() {
    // 使用 StateLayout 控制 Loading, Empty, Error, Success 状态
    StateLayout({
      uiState: this.vm.resultUiState,
      content: () => {
        this.ResultContent()
      }
    })
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
      // 绑定缩放属性，实现一镜到底的背景缩放效果
      .scale({ x: this.vm.pageScale, y: this.vm.pageScale })
      .animation({ duration: 300, curve: Curve.FastOutSlowIn })
  }

  @Builder
  ResultContent() {
    if (this.vm.currentSearchIndex === 0) {
      // --- 搜帖子结果 (瀑布流) ---
      this.ThreadResultList()
    } else {
      // --- 搜用户结果 (Grid) ---
      this.UserResultList()
    }
  }

  @Builder
  ThreadResultList() {
    WaterFlow() {
      LazyForEach(this.vm.threadListDataSource, (item: ForumTieSummary) => {
        FlowItem() {
          TieCard({
            tie: item,
            // 搜索结果中有时包含版块名称
            forumName: item.forum_name || ''
          })
          // 设置 ID 用于一镜到底动画定位
            .id(item.thread_id.toString())
            .onClick(() => {
              // 调用 VM 的方法进入详情
              this.vm.enterDetailPage(item.thread_id.toString(), this.getUIContext(), item);
            })
        }
        .width(CommonConstant.FullPercent)
      }, (item: ForumTieSummary) => item.thread_id.toString())

      // 底部 Loading
      if (this.vm.hasMore) {
        FlowItem() {
          this.LoadingFooter()
        }
      }
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
    // 使用 VM 中的响应式列数配置
    .columnsTemplate('1fr '.repeat(this.vm.columns).trim())
    .columnsGap(CommonConstant.NormalContainerInnerPadding)
    .rowsGap(CommonConstant.NormalContainerInnerPadding)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .padding({
      left: CommonConstant.NormalContainerInnerPadding,
      right: CommonConstant.NormalContainerInnerPadding,
      bottom: CommonConstant.NormalContainerInnerPadding
    })
    .onReachEnd(() => {
      this.vm.loadMore();
    })
  }

  @Builder
  UserResultList() {
    Grid() {
      LazyForEach(this.vm.userListDataSource, (item: SearchUser) => {
        GridItem() {
          this.UserResultItem(item)
        }
      }, (item: SearchUser) => item.uid.toString())

      // 底部 Loading
      if (this.vm.hasMore) {
        GridItem() {
          this.LoadingFooter()
        }
        .columnStart(0)
        .columnEnd(this.vm.columns - 1)
      }
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
    .columnsTemplate('1fr '.repeat(this.vm.columns).trim())
    .columnsGap(CommonConstant.NormalContainerInnerPadding)
    .rowsGap(CommonConstant.NormalContainerInnerPadding)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .padding(CommonConstant.NormalContainerInnerPadding)
    .align(Alignment.TopStart)
    .onReachEnd(() => {
      this.vm.loadMore();
    })
  }

  @Builder
  UserResultItem(item: SearchUser) {
    Row({ space: CommonConstant.NormalContainerInnerPadding }) {
      Image(UserAvatarUtil.getAvatarUrl(item.uid))
        .width(CommonConstant.IconSizeNormal)
        .height(CommonConstant.IconSizeNormal)
        .borderRadius(CommonConstant.RadiusRound)

      Column({ space: 4 }) {
        Text(item.username)
          .fontSize(CommonConstant.TextSizeSmall)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(item.group_title)
          .fontSize(CommonConstant.TextSizeTiny)
          .fontColor($r('sys.color.font_tertiary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width(CommonConstant.FullPercent)
    .padding(CommonConstant.NormalContainerInnerPadding)
    .backgroundColor($r('app.color.second_window_background'))
    .borderRadius(CommonConstant.RadiusNormal)
    .onClick(() => {
      // 跳转用户主页
      // RouterUtil.pushNamedRoute(TransitionMap.UserProfilePage, { uid: item.uid });
    })
  }

  @Builder
  LoadingFooter() {
    Row() {
      LoadingProgress()
        .width(24)
        .height(24)
        .color($r('sys.color.font_secondary'))
      Text("加载中...")
        .fontSize(CommonConstant.TextSizeSmall)
        .fontColor($r('sys.color.font_secondary'))
        .margin({ left: 8 })
    }
    .width(CommonConstant.FullPercent)
    .justifyContent(FlexAlign.Center)
    .padding(16)
  }
}