import { NumberUtil, ResUtil } from '@pura/harmony-utils';
import { CommonConstant, DateUtil, ForumDetailComment, ForumExtraPanel, RouterUtil } from 'base_common';
import { TieContentRender } from './TieContentRender';

@ComponentV2
export struct CommentCard {
  @Param @Require tieComment: ForumDetailComment;
  @Param @Require authorID: number;
  @Param threadId: number = 0;

  private formatPostDate(timestampStr: string): string {
    let timestamp = NumberUtil.toNumber(timestampStr);
    if (!timestamp) {
      return '';
    }

    if (timestamp < 10000000000) {
      timestamp = timestamp * 1000;
    }

    const date = new Date(timestamp);
    const y = date.getFullYear();
    const m = (date.getMonth() + 1).toString().padStart(2, '0');
    const d = date.getDate().toString().padStart(2, '0');
    const h = date.getHours().toString().padStart(2, '0');
    const min = date.getMinutes().toString().padStart(2, '0');
    return `${y}-${m}-${d} ${h}:${min}`;
  }

  private getQuoteContent(): string {
    if (!this.tieComment.reply_content) {
      return '';
    }
    return this.tieComment.reply_content
      .filter(item => item.type === 0)
      .map(item => item.infor)
      .join(' ')
      .trim();
  }

  build() {
    Row({ space: CommonConstant.NormalContainerInnerPadding }) {
      // 1. 头像区
      Column() {
        Stack({ alignContent: Alignment.BottomEnd }) {
          Image(this.tieComment.icon)
            .width(CommonConstant.IconSizeLarge)
            .height(CommonConstant.IconSizeLarge)
            .borderRadius(CommonConstant.RadiusRound)
            .objectFit(ImageFit.Cover)

          if (this.authorID === this.tieComment.reply_id) {
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
          Text(this.tieComment.reply_name)
            .fontSize(CommonConstant.TextSizeSmall)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Bold)

          // 等级徽章 (Lv.X)
          Text(this.tieComment.userTitle)
            .fontSize(CommonConstant.TextSizeTiny)
            .fontColor($r('sys.color.font_tertiary'))
            .fontWeight(FontWeight.Bold)
            .backgroundColor($r('app.color.tetertiary_window_background'))
            .padding(CommonConstant.SmallContainerInnerPadding / 2)
            .borderRadius(CommonConstant.RadiusTiny)

        }
        .width(CommonConstant.FullPercent)

        // 评论内容
        // 传递引用内容（quoteContent）和用户名（quoteUserName）
        TieContentRender({
          contents: this.tieComment.reply_content,
          quoteContent: this.tieComment.quote_content_bare,
          quoteUserName: this.tieComment.quote_user_name,
          isQuote: this.tieComment.is_quote
        })

        // 底部元数据 (时间 · 地点 · 回复)
        Row({ space: CommonConstant.NormalContainerInnerPadding }) {
          Text(`${DateUtil.getRelativeTime(NumberUtil.toNumber(this.tieComment.posts_date))} · ${this.tieComment.position}${ResUtil.getStringSync($r('app.string.TieContentPage_comment_floor'))} ·  ${this.tieComment.mobileSign}`)
            .fontSize(CommonConstant.TextSizeSmall)
            .fontColor($r('sys.color.font_tertiary'))

          Text($r('app.string.TieContentPage_comment_reply'))
            .fontSize(CommonConstant.TextSizeSmall)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_secondary'))
            .onClick(() => {
              if (this.threadId && this.threadId !== 0) {
                const replyDate = this.formatPostDate(this.tieComment.posts_date);
                const quoteContent = this.getQuoteContent();

                RouterUtil.pushPathByName("ReplyPage", {
                  "threadId": this.threadId,
                  "postId": this.tieComment.reply_posts_id,
                  "replyUser": this.tieComment.reply_name,
                  "replyDate": replyDate,
                  "quoteContent": quoteContent
                } as Record<string, Object>, undefined, false);
              }
            })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 3. 右侧点赞区
      Column({ space: CommonConstant.SmallContainerInnerPadding }) {
        SymbolGlyph($r('sys.symbol.heart'))
          .fontSize(CommonConstant.TextSizeLarge)
          .fontColor([$r('sys.color.font_tertiary')])

        Text(
          (this.tieComment.extraPanel.find((item: ForumExtraPanel) => item.type === "support")
          ?.extParams?.recommendAdd || 0).toString()
        )
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