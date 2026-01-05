import { RandomUtil } from '@pura/harmony-utils';
import { CommonConstant, ForumTieSummary, UserAvatarUtil } from 'base_common';

const BASE_URL: string = 'https://bbs.uestc.edu.cn';

@ComponentV2
export struct TieCard {
  @Param @Require tie: ForumTieSummary;
  @Param forumName: string = '';
  @Local scaleVal: number = 1.0;

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
    .backgroundColor($r('app.color.glass_background')) // 半透明黑底
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THICK)
    .borderRadius(CommonConstant.RadiusRound)
    .position({ left: CommonConstant.NormalContainerInnerPadding, top: CommonConstant.NormalContainerInnerPadding })
    .zIndex(2)
  }

  @Builder
  CoverArea() {
    if (this.tie.summary_attachments) {
      Image(BASE_URL + this.tie.summary_attachments[0].thumbnail_url)
        .width(CommonConstant.FullPercent)
        .height(CommonConstant.FullPercent)
        .objectFit(ImageFit.Cover)
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
          .position({ x: -5, y: -5 })
          .rotate({ angle: -10 })
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
    }
  }

  @Builder
  SectionTag() {
    Row({ space: CommonConstant.SmallContainerInnerPadding }) {
      SymbolGlyph($r('sys.symbol.list_number'))
        .fontSize(CommonConstant.TextSizeTiny)
        .fontColor([$r('sys.color.font_tertiary')])

      // 3、补全分类名称
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

  // === 4. 底部小图标文字 ===
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
      // 1. 顶部视觉区 (封面)
      // 使用 Stack 包裹封面和角标
      Stack({ alignContent: Alignment.TopStart }) {
        this.CoverArea()
        this.ViewsBadge()
      }
      .width(CommonConstant.FullPercent)
      .height(RandomUtil.getRandomInt(240, 340)) // 核心：使用数据源中的随机高度来实现瀑布流效果
      .clip(true)
      .backgroundColor($r('app.color.second_window_background'))

      // 2. 底部详细信息区
      Column({ space: CommonConstant.NormalContainerInnerPadding }) {
        // 标题 (如果有封面图，标题显示在下方；如果是纯色背景，标题已经在上面显示了，这里可以不显示或显示摘要)
        if (this.tie.summary_attachments) {
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
          // 如果是纯色海报模式，下方可以显示具体内容摘要
          Text(this.tie.summary)
            .fontSize(CommonConstant.TextSizeNormal)
            .fontColor($r('sys.color.font_secondary'))
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .lineHeight(CommonConstant.TextSizeLarge)
            .textAlign(TextAlign.Start)
            .width(CommonConstant.FullPercent)
        }

        // 底部元数据栏
        Row() {
          // 左侧：用户信息 (头像+昵称)
          Row({ space: CommonConstant.NormalContainerInnerPadding }) {
            // 简单模拟头像，如果有真实头像链接则使用 Image
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
        Row() {
          this.SectionTag()

          Row({ space: CommonConstant.NormalContainerInnerPadding }) {
            this.IconText($r('sys.symbol.message'), this.formatNumber(this.tie.replies))
          }
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width(CommonConstant.FullPercent)
      }
      .padding(CommonConstant.NormalContainerInnerPadding) // 卡片内容内边距
    }
    .width(CommonConstant.FullPercent)
    // === 核心样式 ===
    .backgroundColor($r('app.color.second_window_background'))
    .borderRadius(CommonConstant.RadiusLarge) // 圆角
    .clip(true)
    .scale({ x: this.scaleVal, y: this.scaleVal })
    .animation({
      duration: CommonConstant.AnimationDurationNormal,
      curve: CommonConstant.AnimationCurveSpring
    })
    .onTouch((e) => {
      if (e.type === TouchType.Down) {
        this.scaleVal = 0.95;
      } else if (e.type === TouchType.Up ||
        e.type === TouchType.Cancel) {
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