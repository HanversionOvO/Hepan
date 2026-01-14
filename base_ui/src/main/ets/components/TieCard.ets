import { RandomUtil } from '@pura/harmony-utils';
import {
  AppPreferenceKeys,
  ColorUtil,
  CommonConstant,
  DateUtil,
  ForumTieSummary,
  PreferenceUtil,
  UrlUtil,
  UserAvatarUtil
} from 'base_common';

export function buildTieCardKey(tie: ForumTieSummary): string {
  const attachmentCount = tie.summary_attachments ? tie.summary_attachments.length : 0;
  const subject = tie.subject || '';
  const summary = tie.summary || '';
  return `${tie.thread_id}_${tie.last_post}_${tie.replies}_${tie.views}_${attachmentCount}_${subject}_${summary}`;
}

@ComponentV2
export struct TieCard {
  @Param @Require tie: ForumTieSummary;
  @Param forumName: string = '';
  @Param pubTimeLabel: string = '';
  @Param watermarkText: string = '';
  @Local scaleVal: number = 1.0;
  @Local minCoverHeight: number = 200;
  @Local maxCoverHeight: number = 260;
  @Local randomHeight: number = RandomUtil.getRandomInt(this.minCoverHeight, this.maxCoverHeight);
  @Local baseUrl: string = CommonConstant.BASE_URL;

  aboutToAppear(): void {
    this.loadBaseUrl();
  }

  private loadBaseUrl(): void {
    const storedBaseUrl = PreferenceUtil.read<string>(AppPreferenceKeys.prefName, (pref) => {
      return pref.getSync(AppPreferenceKeys.baseUrl, CommonConstant.BASE_URL) as string;
    }, CommonConstant.BASE_URL);
    this.baseUrl = storedBaseUrl ? storedBaseUrl : CommonConstant.BASE_URL;
  }

  private getCoverUrl(): string | null {
    const attachments = this.tie.summary_attachments;
    if (!attachments || attachments.length === 0) {
      return null;
    }
    const imgItem = attachments.find(item => item.is_image === 1);
    if (!imgItem) {
      return null;
    }
    const path = imgItem.thumbnail_url || imgItem.raw_url || imgItem.download_url || imgItem.path;
    if (!path) {
      return null;
    }
    return UrlUtil.buildUrl(this.baseUrl, path);
  }

  private getAuthorAvatar(): ResourceStr {
    return this.tie.author_id === 0 ? $r('app.media.anonymous') : UserAvatarUtil.getAvatarUrl(this.tie.author_id);
  }

  private getCoverSeed(): string | number {
    if (this.tie.thread_id) {
      return this.tie.thread_id;
    }
    if (this.tie.author_id) {
      return this.tie.author_id;
    }
    if (this.tie.subject) {
      return this.tie.subject;
    }
    return this.tie.summary || 'tie_card';
  }

  private getCoverBaseColor(): string {
    return ColorUtil.getStableColor(this.getCoverSeed());
  }

  private getCoverGradient(): LinearGradientOptions {
    return ColorUtil.buildDiagonalGradient(this.getCoverBaseColor());
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
  PinnedBadge() {
    if (this.tie.display_order > 0) {
      Row({ space: CommonConstant.SmallContainerInnerPadding }) {
        SymbolGlyph($r('sys.symbol.pin_fill'))
          .fontSize(CommonConstant.TextSizeTiny)
          .fontColor([$r('sys.color.font_on_primary')])
        Text($r('app.string.TieCard_pinned'))
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
      .backgroundColor(ColorUtil.opacity(CommonConstant.ThemeColor, 0.6))
      .backgroundBlurStyle(BlurStyle.BACKGROUND_THICK)
      .borderRadius(CommonConstant.RadiusRound)
      .position({ right: CommonConstant.NormalContainerInnerPadding, top: CommonConstant.NormalContainerInnerPadding })
      .zIndex(2)
    }
  }

  @Builder
  CoverArea() {
    if (this.getCoverUrl()) {
      Image(this.getCoverUrl())
        .width(CommonConstant.FullPercent)
        .constraintSize({ minHeight: this.minCoverHeight, maxHeight: this.maxCoverHeight })
        .objectFit(ImageFit.Cover)
        .align(Alignment.Top)
    } else {
      Stack() {
        Column()
          .width(CommonConstant.FullPercent)
          .height(CommonConstant.FullPercent)
          .backgroundColor(this.getCoverBaseColor())
          .linearGradient(this.getCoverGradient())

        if (this.watermarkText) {
          Text(this.watermarkText)
            .fontSize(CommonConstant.TextSizeUltraLarge)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_on_tertiary'))
            .rotate({ angle: -10 })
            .position({ left: 0, top: 0 })
            .opacity(0.4)
        }

        Column() {
          Text('"')
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
        this.PinnedBadge()
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
            Image(this.getAuthorAvatar())
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

        Column({ space: CommonConstant.SmallContainerInnerPadding }) {
          Row() {
            if (this.forumName) {
              this.SectionTag()
            }

            Row({ space: CommonConstant.NormalContainerInnerPadding }) {
              this.IconText($r('sys.symbol.message'), this.formatNumber(this.tie.replies))
            }
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width(CommonConstant.FullPercent)

          Text(`${this.pubTimeLabel} ${DateUtil.getRelativeTime(this.tie.dateline)}`.trim())
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
    .animation({
      duration: CommonConstant.AnimationDurationNormal,
      curve: CommonConstant.AnimationCurveSpring
    })
    .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.85 })
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
