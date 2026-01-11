import {
  CommonConstant, DateUtil, ForumTieSummary, SearchUser, UserAvatarUtil
} from 'base_common';
import { SearchPageVM } from '../viewmodels/SearchPageVM';

@ComponentV2
export struct ReviewView {
  @Param vm: SearchPageVM = new SearchPageVM();

  aboutToAppear(): void {
    this.vm.updateGridConfig(this.vm.breakPoint.currentBreakPoint);
  }

  build() {
    Grid() {
      if (this.vm.searchSummary) {
        // ---------------------------------------------------------
        // 1. ID 精确匹配 (帖子)
        // ---------------------------------------------------------
        if (this.vm.searchSummary.tid_match) {
          // 标题：跨越所有列
          GridItem() {
            this.SectionTitle('ID 精确匹配 (帖子)')
          }
          .columnStart(0)
          .columnEnd(this.vm.columns - 1)

          // 内容：跨越所有列 (精确匹配通常值得突出显示)
          GridItem() {
            this.SimpleTieItem(this.vm.searchSummary.tid_match!)
          }
          .columnStart(0)
          .columnEnd(this.vm.columns - 1)
        }

        // ---------------------------------------------------------
        // 2. ID 精确匹配 (用户)
        // ---------------------------------------------------------
        if (this.vm.searchSummary.uid_match) {
          GridItem() {
            this.SectionTitle('ID 精确匹配 (用户)')
          }
          .columnStart(0)
          .columnEnd(this.vm.columns - 1)

          GridItem() {
            this.SimpleUserItem(this.vm.searchSummary.uid_match!)
          }
          .columnStart(0)
          .columnEnd(this.vm.columns - 1)
        }

        // ---------------------------------------------------------
        // 3. 相关帖子列表
        // ---------------------------------------------------------
        if (this.vm.searchSummary.threads && this.vm.searchSummary.threads.length > 0) {
          GridItem() {
            this.SectionTitle(`相关帖子 (${this.vm.searchSummary.thread_count}+)`)
          }
          .columnStart(0)
          .columnEnd(this.vm.columns - 1)

          ForEach(this.vm.searchSummary.threads, (thread: ForumTieSummary) => {
            GridItem() {
              this.SimpleTieItem(thread)
            }

            // 普通项不设置跨列，自动跟随 columnsTemplate
          }, (thread: ForumTieSummary) => thread.thread_id.toString())
        }

        // ---------------------------------------------------------
        // 4. 相关用户列表
        // ---------------------------------------------------------
        if (this.vm.searchSummary.users && this.vm.searchSummary.users.length > 0) {
          GridItem() {
            this.SectionTitle(`相关用户 (${this.vm.searchSummary.user_count}+)`)
          }
          .columnStart(0)
          .columnEnd(this.vm.columns - 1)

          ForEach(this.vm.searchSummary.users, (user: SearchUser) => {
            GridItem() {
              this.SimpleUserItem(user)
            }
          }, (user: SearchUser) => user.uid.toString())
        }

      }
    }
    .columnsTemplate('1fr '.repeat(this.vm.columns).trim())
    .columnsGap(CommonConstant.NormalContainerInnerPadding)
    .rowsGap(CommonConstant.NormalContainerInnerPadding)
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .padding({
      left: CommonConstant.PageLRPadding,
      right: CommonConstant.PageLRPadding
    })
    .align(Alignment.TopStart)
  }

  @Builder
  SectionTitle(title: string) {
    Text(title)
      .fontSize(CommonConstant.TextSizeNormal)
      .fontWeight(FontWeight.Bold)
      .fontColor($r('sys.color.font_secondary'))
      .width(CommonConstant.FullPercent)
  }

  @Builder
  SimpleTieItem(item: ForumTieSummary) {
    Row({ space: CommonConstant.NormalContainerInnerPadding }) {
      Image(UserAvatarUtil.getAvatarUrl(item.author_id))
        .width(CommonConstant.IconSizeNormal)
        .height(CommonConstant.IconSizeNormal)
        .borderRadius(CommonConstant.RadiusRound)

      Column({ space: CommonConstant.SmallContainerInnerPadding }) {
        Text(item.subject)
          .fontSize(CommonConstant.TextSizeSmall)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row({ space: CommonConstant.SmallContainerInnerPadding }) {
          Text(item.author)
            .fontSize(CommonConstant.TextSizeTiny)
            .fontColor($r('sys.color.font_secondary'))

          Text(DateUtil.getRelativeTime(item.dateline))
            .fontSize(CommonConstant.TextSizeTiny)
            .fontColor($r('sys.color.font_tertiary'))
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width(CommonConstant.FullPercent)
    .padding(CommonConstant.NormalContainerInnerPadding)
    .backgroundColor($r('app.color.second_window_background'))
    .borderRadius(CommonConstant.RadiusNormal)
    .onClick(() => {
      // RouterUtil.pushNamedRoute(TransitionMap.TieContentPage, { tid: item.thread_id });
    })
  }

  @Builder
  SimpleUserItem(item: SearchUser) {
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

        Text(item.group_title)
          .fontSize(CommonConstant.TextSizeTiny)
          .fontColor($r('sys.color.font_tertiary'))
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width(CommonConstant.FullPercent)
    .padding(CommonConstant.NormalContainerInnerPadding)
    .backgroundColor($r('app.color.second_window_background'))
    .borderRadius(CommonConstant.RadiusNormal)
    .onClick(() => {
      // RouterUtil.pushNamedRoute(TransitionMap.UserProfilePage, { uid: item.uid });
    })
  }
}