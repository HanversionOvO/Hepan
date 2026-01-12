import { ResUtil } from '@pura/harmony-utils';
import { CommonConstant, DateUtil, RouterUtil, TieRow, UserAvatarUtil } from 'base_common';
import { TieContentRender } from './TieContentRender';

@ComponentV2
export struct CommentCard {
  @Param @Require tieComment: TieRow;
  @Param @Require authorID: number;
  @Param threadId: number = 0;
  @Param highlightId: number = 0;
  @Param highlightToken: number = 0;
  @Local scaleVal: number = 1.0;
  private lastHighlightToken: number = -1;

  aboutToAppear(): void {
    this.tryHighlight();
  }

  @Monitor('highlightToken')
  onHighlightTokenChange(): void {
    this.tryHighlight();
  }

  private tryHighlight(): void {
    if (!this.highlightId || this.tieComment.post_id !== this.highlightId) {
      return;
    }
    if (this.lastHighlightToken === this.highlightToken) {
      return;
    }
    this.lastHighlightToken = this.highlightToken;
    this.runPulseAnimation();
  }

  private runPulseAnimation(): void {
    const pulseTimes = 3;
    const scaleUp = 1.04;
    const duration = CommonConstant.AnimationDurationFast;
    let step = 0;
    const animateStep = () => {
      const isUp = step % 2 === 0;
      animateTo({ duration: duration, curve: CommonConstant.AnimationCurveSpring }, () => {
        this.scaleVal = isUp ? scaleUp : 1.0;
      });
      step += 1;
      if (step < pulseTimes * 2) {
        setTimeout(animateStep, duration + 30);
      }
    };
    animateStep();
  }

  private formatPostDate(timestamp: number): string {
    if (!timestamp) {
      return '';
    }
    const finalTimestamp = timestamp < 10000000000 ? timestamp * 1000 : timestamp;
    const date = new Date(finalTimestamp);
    const y = date.getFullYear();
    const m = (date.getMonth() + 1).toString().padStart(2, '0');
    const d = date.getDate().toString().padStart(2, '0');
    const h = date.getHours().toString().padStart(2, '0');
    const min = date.getMinutes().toString().padStart(2, '0');
    return `${y}-${m}-${d} ${h}:${min}`;
  }

  build() {
    Row({ space: CommonConstant.NormalContainerInnerPadding }) {
      Column() {
        Stack({ alignContent: Alignment.BottomEnd }) {
          Image(UserAvatarUtil.getAvatarUrl(this.tieComment.author_id))
            .width(CommonConstant.IconSizeLarge)
            .height(CommonConstant.IconSizeLarge)
            .borderRadius(CommonConstant.RadiusRound)
            .objectFit(ImageFit.Cover)

          if (this.authorID === this.tieComment.author_id) {
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

      Column({ space: CommonConstant.NormalContainerInnerPadding }) {
        Row({ space: CommonConstant.SmallContainerInnerPadding }) {
          Text(this.tieComment.author)
            .fontSize(CommonConstant.TextSizeSmall)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Bold)

          Text(this.tieComment.author_details?.group_title || '')
            .fontSize(CommonConstant.TextSizeTiny)
            .fontColor($r('sys.color.font_tertiary'))
            .fontWeight(FontWeight.Bold)
            .backgroundColor($r('app.color.tetertiary_window_background'))
            .padding(CommonConstant.SmallContainerInnerPadding / 2)
            .borderRadius(CommonConstant.RadiusTiny)
        }
        .width(CommonConstant.FullPercent)

        TieContentRender({
          message: this.tieComment.message,
          format: this.tieComment.format,
          attachments: this.tieComment.attachments || []
        })

        Row({ space: CommonConstant.NormalContainerInnerPadding }) {
          Text(`${DateUtil.getRelativeTime(this.tieComment.dateline)} · ${this.tieComment.position}` +
            ResUtil.getStringSync($r('app.string.TieContentPage_comment_floor')))
            .fontSize(CommonConstant.TextSizeSmall)
            .fontColor($r('sys.color.font_tertiary'))

          Text($r('app.string.TieContentPage_comment_reply'))
            .fontSize(CommonConstant.TextSizeSmall)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_secondary'))
            .onClick(() => {
              if (this.threadId && this.threadId !== 0) {
                const replyDate = this.formatPostDate(this.tieComment.dateline);
                const quoteContent = this.tieComment.message || '';

                RouterUtil.pushPathByName("ReplyPage", {
                  "threadId": this.threadId,
                  "postId": this.tieComment.post_id,
                  "replyUser": this.tieComment.author,
                  "replyDate": replyDate,
                  "quoteContent": quoteContent
                } as Record<string, Object>, undefined, false);
              }
            })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Column({ space: CommonConstant.SmallContainerInnerPadding }) {
        SymbolGlyph($r('sys.symbol.heart'))
          .fontSize(CommonConstant.TextSizeLarge)
          .fontColor([$r('sys.color.font_tertiary')])

        Text((this.tieComment.support || 0).toString())
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
    .scale({ x: this.scaleVal, y: this.scaleVal })
  }
}
