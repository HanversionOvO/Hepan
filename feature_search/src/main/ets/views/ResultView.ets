import {
  CommonConstant, ForumTieSummary, RouterMap, RouterUtil, SearchUser, UserAvatarUtil
} from 'base_common';
import { StateLayout } from 'base_ui';
import { SearchPageVM } from '../viewmodels/SearchPageVM';
import { TieCard } from 'feature_content/src/main/ets/components/TieCard';

@ComponentV2
export struct ResultView {
  @Param @Require vm: SearchPageVM;

  aboutToAppear() {
    this.vm.updateGridConfig(this.vm.breakPoint.currentBreakPoint)
  }

  build() {
    StateLayout({
      uiState: this.vm.resultUiState,
      content: () => {
        this.ResultContent()
      }
    })
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
      .scale({ x: this.vm.pageScale, y: this.vm.pageScale })
      .animation({ duration: CommonConstant.AnimationDurationNormal, curve: Curve.FastOutSlowIn })
  }

  @Builder
  ResultContent() {
    if (this.vm.currentSearchIndex === 0) {
      this.ThreadResultList()
    } else {
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
            forumName: item.forum_name || ''
          })
            .id(item.thread_id.toString())
            .onClick(() => {
              this.vm.enterDetailPage(item.thread_id.toString(), this.getUIContext(), item);
            })
        }
        .width(CommonConstant.FullPercent)
      }, (item: ForumTieSummary) => item.thread_id.toString())
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
    .columnsTemplate('1fr '.repeat(this.vm.postColumn).trim())
    .columnsGap(CommonConstant.NormalContainerInnerPadding)
    .rowsGap(CommonConstant.NormalContainerInnerPadding)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .padding({
      left: CommonConstant.PageLRPadding,
      right: CommonConstant.PageLRPadding
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
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
    .columnsTemplate('1fr '.repeat(this.vm.columns).trim())
    .columnsGap(CommonConstant.NormalContainerInnerPadding)
    .rowsGap(CommonConstant.NormalContainerInnerPadding)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .padding({
      left: CommonConstant.PageLRPadding,
      right: CommonConstant.PageLRPadding
    })
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

      Column({ space: CommonConstant.SmallContainerInnerPadding }) {
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
      RouterUtil.pushPathByName(RouterMap.USER_PROFILE, item.uid);
    })
  }
}