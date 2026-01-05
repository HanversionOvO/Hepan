import { RandomUtil, ResUtil } from '@pura/harmony-utils';
import { CommonConstant, DateUtil, ForumTieSummary, UserAvatarUtil } from 'base_common';

const BASE_URL: string = 'https://bbs.uestc.edu.cn';

@ComponentV2
export struct TieCard {
  @Param @Require tie: ForumTieSummary;
  @Param forumName: string = '';
  @Local scaleVal: number = 1.0;
  @Local minCoverHeight: number = 200;
  @Local maxCoverHeight: number = 260;
  @Local randomHeight: number = RandomUtil.getRandomInt(this.minCoverHeight, this.maxCoverHeight);

  getCoverUrl(): string | null {
    if (this.tie.summary_attachments && this.tie.summary_attachments.length > 0) {
      const imgItem = this.tie.summary_attachments.find(item => item.is_image === 1);
      if (imgItem) {
        return BASE_URL + imgItem.thumbnail_url;
      }
    }
    return null;
  }

  @Builder
  ViewsBadge() {
    Row({ space: CommonConstant.SmallContainerInnerPadding }) {
      SymbolGlyph($r('sys.symbol.eye'))
        .fontSize(CommonConstant.TextSizeTiny)
        .fontColor([$r('sys.color.font_on_primary')])
      Text(this.formatNumber(this.tie.views))
        .fontSize(CommonConstant.TextSizeTiny)
        .fontColor($r('sys.color.font_on_primary'))
        .fontWeight(FontWeight.Medium)
    }
    .padding({
      left: CommonConstant.SmallContainerLRPadding / 2,
      right: CommonConstant.SmallContainerLRPadding / 2,
      top: CommonConstant.SmallContainerTBPadding / 2,
      bottom: CommonConstant.SmallContainerTBPadding / 2
    })
    .backgroundColor($r('app.color.glass_background'))
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THICK)
    .borderRadius(CommonConstant.RadiusRound)
    .position({ left: CommonConstant.NormalContainerInnerPadding, top: CommonConstant.NormalContainerInnerPadding })
    .zIndex(2)
  }

  @Builder
  CoverArea() {
    // 封面区域逻辑
    if (this.getCoverUrl()) {
      Image(this.getCoverUrl())
        .width(CommonConstant.FullPercent)
        .constraintSize({ maxHeight: this.maxCoverHeight })
        .objectFit(ImageFit.Cover)
        .align(Alignment.Top)
    } else {
      Stack() {
        Column()
          .width(CommonConstant.FullPercent)
          .height(CommonConstant.FullPercent)
          .backgroundColor(RandomUtil.getRandomColor())

        // 装饰水印
        Text($r('app.string.ContentPage_title'))
          .fontSize(CommonConstant.TextSizeUltraLarge)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_on_tertiary'))
          .rotate({ angle: -10 })
          .position({ left: 0, top: 0 })
          .opacity(0.4)

        // 居中引语
        Column() {
          Text('“')
            .fontSize(CommonConstant.TextSizeUltraLarge)
            .fontColor($r('sys.color.font_on_primary'))
            .opacity(0.8)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: -5, left: -2 })

          Text(this.tie.subject)
            .fontSize(CommonConstant.TextSizeLarge)
            .fontWeight(FontWeight.Bolder)
            .fontColor($r('sys.color.font_on_primary'))
            .maxLines(4)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .lineHeight(CommonConstant.TextSizeUltraLarge)
            .fontStyle(FontStyle.Italic)
            .textShadow({ radius: 5, color: 'rgba(0,0,0,0.1)', offsetY: 2 })
        }
        .padding(CommonConstant.PageLRPadding)
        .width(CommonConstant.FullPercent)
        .height(CommonConstant.FullPercent)
        .justifyContent(FlexAlign.Center)
      }
      .width(CommonConstant.FullPercent)
      .height(this.randomHeight)
    }
  }

  @Builder
  SectionTag() {
    Row({ space: CommonConstant.SmallContainerInnerPadding }) {
      SymbolGlyph($r('sys.symbol.list_number'))
        .fontSize(CommonConstant.TextSizeTiny)
        .fontColor([$r('sys.color.font_tertiary')])

      Text(this.forumName)
        .fontSize(CommonConstant.TextSizeTiny)
        .fontColor($r('sys.color.font_tertiary'))
        .fontWeight(FontWeight.Medium)
    }
    .padding({
      left: CommonConstant.SmallContainerLRPadding / 2,
      right: CommonConstant.SmallContainerLRPadding / 2,
      top: CommonConstant.SmallContainerTBPadding / 2,
      bottom: CommonConstant.SmallContainerTBPadding / 2
    })
    .backgroundColor($r('app.color.start_window_background'))
    .borderRadius(CommonConstant.RadiusRound)
  }

  @Builder
  IconText(icon: Resource, text: string) {
    Row({ space: CommonConstant.SmallContainerInnerPadding }) {
      SymbolGlyph(icon)
        .fontSize(CommonConstant.TextSizeSmall)
        .fontColor([$r('sys.color.font_secondary')])
      Text(text)
        .fontSize(CommonConstant.TextSizeSmall)
        .fontColor($r('sys.color.font_secondary'))
    }
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        this.CoverArea()
        this.ViewsBadge()
      }
      .width(CommonConstant.FullPercent)
      .clip(true)
      .backgroundColor($r('app.color.second_window_background'))

      Column({ space: CommonConstant.NormalContainerInnerPadding }) {
        if (this.getCoverUrl()) {
          Text(this.tie.subject)
            .fontSize(CommonConstant.TextSizeNormal)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .lineHeight(CommonConstant.TextSizeLarge)
            .textAlign(TextAlign.Start)
            .width(CommonConstant.FullPercent)
        } else {
          Text(this.tie.summary)
            .fontSize(CommonConstant.TextSizeNormal)
            .fontColor($r('sys.color.font_secondary'))
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .lineHeight(CommonConstant.TextSizeLarge)
            .textAlign(TextAlign.Start)
            .width(CommonConstant.FullPercent)
        }

        Row() {
          Row({ space: CommonConstant.SmallContainerInnerPadding }) {
            Image(UserAvatarUtil.getAvatarUrl(this.tie.author_id))
              .width(CommonConstant.IconSizeSmall)
              .height(CommonConstant.IconSizeSmall)
              .borderRadius(CommonConstant.RadiusRound)

            Text(this.tie.author)
              .fontSize(CommonConstant.TextSizeSmall)
              .fontColor($r('sys.color.font_secondary'))
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
          }
          .layoutWeight(1)
        }
        .width(CommonConstant.FullPercent)
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)

        // 标签栏
        Column({ space: CommonConstant.SmallContainerInnerPadding }) {
          Row() {
            this.SectionTag()

            Row({ space: CommonConstant.NormalContainerInnerPadding }) {
              this.IconText($r('sys.symbol.message'), this.formatNumber(this.tie.replies))
            }
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width(CommonConstant.FullPercent)

          Text(ResUtil.getStringSync($r('app.string.TieView_card_pub_time')) + " " +
          DateUtil.getRelativeTime(this.tie.dateline))
            .width(CommonConstant.FullPercent)
            .textAlign(TextAlign.End)
            .fontColor($r('sys.color.font_tertiary'))
            .fontSize(CommonConstant.TextSizeTiny)
        }
        .width(CommonConstant.FullPercent)
      }
      .padding(CommonConstant.NormalContainerInnerPadding)
    }
    .width(CommonConstant.FullPercent)
    .backgroundColor($r('app.color.second_window_background'))
    .borderRadius(CommonConstant.RadiusLarge)
    .clip(true)
    .scale({ x: this.scaleVal, y: this.scaleVal })
    .animation({
      duration: CommonConstant.AnimationDurationNormal,
      curve: CommonConstant.AnimationCurveSpring
    })
    .onTouch((e) => {
      if (e.type === TouchType.Down) {
        this.scaleVal = 0.95;
      } else if (e.type === TouchType.Up || e.type === TouchType.Cancel) {
        this.scaleVal = 1.0;
      }
    })
  }

  formatNumber(num: number): string {
    if (num >= 10000) {
      return (num / 10000).toFixed(1) + 'w';
    }
    if (num >= 1000) {
      return (num / 1000).toFixed(1) + 'k';
    }
    return num.toString();
  }
}