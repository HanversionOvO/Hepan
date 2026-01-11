import { CommonConstant, DateUtil, ForumTieSummary, SearchUser, UserAvatarUtil } from 'base_common';
import { SearchPageVM } from '../viewmodels/SearchPageVM';

@ComponentV2
export struct ReviewView {
  @Param vm: SearchPageVM = new SearchPageVM();

  aboutToAppear(): void {
    this.vm.updateGridConfig(this.vm.breakPoint.currentBreakPoint)
  }

  build() {
    Scroll() {
      Column({ space: CommonConstant.NormalContainerInnerPadding }) {
        if (this.vm.searchSummary) {
          if (this.vm.searchSummary.tid_match) {
            this.SectionTitle('ID 精确匹配 (帖子)')
            Grid() {
              GridItem() {
                this.SimpleTieItem(this.vm.searchSummary.tid_match)
              }
              .width(CommonConstant.FullPercent)
            }
            .width(CommonConstant.FullPercent)
            .columnsTemplate('1fr '.repeat(this.vm.columns)
              .trim())
            .columnsGap(CommonConstant.NormalContainerInnerPadding)
            .rowsGap(CommonConstant.NormalContainerInnerPadding)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)
          }

          if (this.vm.searchSummary.uid_match) {
            this.SectionTitle('ID 精确匹配 (用户)')

            Grid() {
              GridItem() {
                this.SimpleUserItem(this.vm.searchSummary.uid_match)
              }
              .width(CommonConstant.FullPercent)
            }
            .width(CommonConstant.FullPercent)
            .columnsTemplate('1fr '.repeat(this.vm.columns)
              .trim())
            .columnsGap(CommonConstant.NormalContainerInnerPadding)
            .rowsGap(CommonConstant.NormalContainerInnerPadding)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)
          }

          // 2. 帖子预览
          if (this.vm.searchSummary.threads && this.vm.searchSummary.threads.length > 0) {
            this.SectionTitle(`相关帖子 (${this.vm.searchSummary.thread_count}+)`)

            Grid() {
              ForEach(this.vm.searchSummary.threads, (thread: ForumTieSummary) => {
                GridItem() {
                  this.SimpleTieItem(thread)
                }
                .width(CommonConstant.FullPercent)
              }, (thread: ForumTieSummary) => thread.thread_id.toString())
            }
            .width(CommonConstant.FullPercent)
            .columnsTemplate('1fr '.repeat(this.vm.columns)
              .trim())
            .columnsGap(CommonConstant.NormalContainerInnerPadding)
            .rowsGap(CommonConstant.NormalContainerInnerPadding)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)
          }

          // 3. 用户预览
          if (this.vm.searchSummary.users && this.vm.searchSummary.users.length > 0) {
            this.SectionTitle(`相关用户 (${this.vm.searchSummary.user_count}+)`)
            Grid() {
              ForEach(this.vm.searchSummary.users, (user: SearchUser) => {
                GridItem() {
                  this.SimpleUserItem(user)
                }
                .width(CommonConstant.FullPercent)
              }, (user: SearchUser) => user.uid.toString())
            }
            .width(CommonConstant.FullPercent)
            .columnsTemplate('1fr '.repeat(this.vm.columns)
              .trim())
            .columnsGap(CommonConstant.NormalContainerInnerPadding)
            .rowsGap(CommonConstant.NormalContainerInnerPadding)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)
          }
        }
      }
      .width(CommonConstant.FullPercent)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
    }
    .width(CommonConstant.FullPercent)
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  SectionTitle(title: string) {
    Text(title)
      .fontSize(CommonConstant.TextSizeNormal)
      .fontWeight(FontWeight.Bold)
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
    .padding({
      left: CommonConstant.NormalContainerLRPadding,
      right: CommonConstant.NormalContainerLRPadding,
      top: CommonConstant.NormalContainerTBPadding,
      bottom: CommonConstant.NormalContainerTBPadding
    })
    .backgroundColor($r('app.color.second_window_background'))
    .borderRadius(CommonConstant.RadiusNormal)
    .onClick(() => {
      // RouterUtil.pushNamedRoute(TransitionMap.UserProfilePage, { uid: item.uid });
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

        Text(item.group_title)
          .fontSize(CommonConstant.TextSizeTiny)
          .fontColor($r('sys.color.font_tertiary'))
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width(CommonConstant.FullPercent)
    .padding({
      left: CommonConstant.NormalContainerLRPadding,
      right: CommonConstant.NormalContainerLRPadding,
      top: CommonConstant.NormalContainerTBPadding,
      bottom: CommonConstant.NormalContainerTBPadding
    })
    .backgroundColor($r('app.color.second_window_background'))
    .borderRadius(CommonConstant.RadiusNormal)
    .onClick(() => {
      // RouterUtil.pushNamedRoute(TransitionMap.UserProfilePage, { uid: item.uid });
    })
  }
}