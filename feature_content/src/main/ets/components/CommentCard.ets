import { ResUtil } from '@pura/harmony-utils';
import { CommonConstant, DateUtil, TieRow, TieThread, UserAvatarUtil } from 'base_common';
import { CustomMarkdown } from 'base_ui';

@ComponentV2
export struct CommentCard {
  @Param @Require thread: TieThread;
  @Param @Require comment: TieRow;

  build() {
    Row({ space: CommonConstant.NormalContainerInnerPadding }) {
      // 1. 头像区
      Column() {
        Stack({ alignContent: Alignment.BottomEnd }) {
          Image(UserAvatarUtil.getAvatarUrl(this.comment.author_id))
            .width(CommonConstant.IconSizeLarge)
            .height(CommonConstant.IconSizeLarge)
            .borderRadius(CommonConstant.RadiusRound)
            .objectFit(ImageFit.Cover)

          if (this.thread.author_id === this.comment.author_id) {
            Text($r('app.string.TieContentPage_comment_card_author'))
              .fontSize(CommonConstant.TextSizeUltraTiny)
              .fontColor($r('sys.color.font_on_primary'))
              .backgroundColor(CommonConstant.ThemeColor)
              .padding(CommonConstant.SmallContainerInnerPadding / 2)
              .borderRadius(CommonConstant.RadiusRound)
              .border({ width: CommonConstant.BorderSizeNormal, color: $r('sys.color.font_on_primary') })
              .margin({
                right: -CommonConstant.SmallContainerInnerPadding,
                bottom: -CommonConstant.SmallContainerInnerPadding
              })
          }
        }
      }
      .width(CommonConstant.IconSizeLarge)
      .alignItems(HorizontalAlign.Start)

      // 2. 主内容区
      Column({ space: CommonConstant.NormalContainerInnerPadding }) {
        // 用户信息行
        Row({ space: CommonConstant.SmallContainerInnerPadding }) {
          Text(this.comment.author)
            .fontSize(CommonConstant.TextSizeSmall)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Bold)

          // 等级徽章 (Lv.X)
          Text(this.comment.author_details?.group_title)
            .fontSize(CommonConstant.TextSizeTiny)
            .fontColor($r('sys.color.font_tertiary'))
            .fontWeight(FontWeight.Bold)
            .backgroundColor($r('app.color.tetertiary_window_background'))
            .padding(CommonConstant.SmallContainerInnerPadding / 2)
            .borderRadius(CommonConstant.RadiusTiny)

        }
        .width(CommonConstant.FullPercent)

        // 评论内容
        CustomMarkdown({
          content: this.comment.message
        })

        // 底部元数据 (时间 · 地点 · 回复)
        Row({ space: CommonConstant.NormalContainerInnerPadding }) {
          Text(`${DateUtil.getRelativeTime(this.comment.dateline)} · ${this.comment.position}${ResUtil.getStringSync($r('app.string.TieContentPage_comment_floor'))}`)
            .fontSize(CommonConstant.TextSizeSmall)
            .fontColor($r('sys.color.font_tertiary'))

          Text($r('app.string.TieContentPage_comment_reply'))
            .fontSize(CommonConstant.TextSizeSmall)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_secondary'))
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 3. 右侧点赞区
      Column({ space: CommonConstant.SmallContainerInnerPadding }) {
        SymbolGlyph($r('sys.symbol.heart'))
          .fontSize(CommonConstant.TextSizeLarge)
          .fontColor([$r('sys.color.font_tertiary')])

        Text(this.comment.support.toString())
          .fontSize(CommonConstant.TextSizeSmall)
          .fontColor($r('sys.color.font_tertiary'))
      }
      .alignItems(HorizontalAlign.Center)
    }
    .width(CommonConstant.FullPercent)
    .alignItems(VerticalAlign.Top)
    .padding({
      top: CommonConstant.NormalContainerTBPadding,
      bottom: CommonConstant.NormalContainerTBPadding,
    })
  }
}