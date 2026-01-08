import { Collection, ColorUtil, CommonConstant, UserAvatarUtil } from 'base_common';
import { LengthMetrics } from '@kit.ArkUI';
import { ResUtil } from '@pura/harmony-utils';

@ComponentV2
export struct CollectionCard {
  @Param @Require collection: Collection;
  @Local topCardSize: number = 58;

  @Builder
  topicIconBuilder() {
    Stack({ alignContent: Alignment.Top }) {
      Divider()
        .width(CommonConstant.FullPercent)
        .strokeWidth(CommonConstant.BorderSizeHuge)
        .color(CommonConstant.ThemeColor)

      Column({ space: CommonConstant.SmallContainerInnerPadding }) {
        Text($r('app.string.CollectionView_topic'))
          .width(CommonConstant.FullPercent)
          .fontSize(CommonConstant.TextSizeTiny)
          .textAlign(TextAlign.Start)
          .fontColor($r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Medium)

        Text(this.collection.collection_nums.toString())
          .fontSize(CommonConstant.TextSizeLarge)
          .fontColor($r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Bolder)
      }
      .padding({
        left: CommonConstant.SmallContainerTBPadding / 2,
        right: CommonConstant.SmallContainerTBPadding / 2,
        top: CommonConstant.SmallContainerTBPadding,
        bottom: CommonConstant.SmallContainerTBPadding
      })
    }
    .width(this.topCardSize)
    .height(this.topCardSize)
    .borderRadius(CommonConstant.RadiusNormal)
    .backgroundColor(ColorUtil.opacity(CommonConstant.ThemeColor))
    .clip(true)
  }

  @Builder
  tag(tagName: string) {
    Text(tagName)
      .padding(CommonConstant.SmallContainerInnerPadding)
      .fontSize(CommonConstant.TextSizeTiny)
      .backgroundColor($r('app.color.start_window_background'))
      .borderRadius(CommonConstant.RadiusSmall)
      .fontColor($r('sys.color.font_tertiary'))
      .fontWeight(FontWeight.Medium)
  }

  @Builder
  content() {
    Column({ space: CommonConstant.LargeContainerInnerPadding }) {
      Column({ space: CommonConstant.SmallContainerInnerPadding }) {
        Text(this.collection.title)
          .fontSize(CommonConstant.TextSizeNormal)
          .width(CommonConstant.FullPercent)
          .textAlign(TextAlign.Start)
          .fontWeight(FontWeight.Bold)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)

        Text(this.collection.description)
          .width(CommonConstant.FullPercent)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(3)
          .textAlign(TextAlign.Start)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize(CommonConstant.TextSizeSmall)
      }
      .width(CommonConstant.FullPercent)

      Column({ space: CommonConstant.SmallContainerInnerPadding }) {
        Flex({
          direction: FlexDirection.Row,
          space: {
            main: LengthMetrics.vp(CommonConstant.NormalContainerInnerPadding)
          }
        }) {
          ForEach(this.collection?.tags, (tag: string, index: number) => {
            this.tag(tag)
          }, (tag: string, index: number) => `${tag}_${index}`)
        }
        .width(CommonConstant.FullPercent)

        Row() {
          Row({ space: CommonConstant.SmallContainerInnerPadding }) {
            Image(UserAvatarUtil.getAvatarUrl(this.collection.creator.uid))
              .width(CommonConstant.IconSizeSmall)
              .height(CommonConstant.IconSizeSmall)
              .borderRadius(CommonConstant.RadiusRound)

            Text(this.collection.creator.username)
              .fontSize(CommonConstant.TextSizeSmall)
          }

          Text(`${ResUtil.getStringSync($r('app.string.CollectionView_subs'))}: ${this.collection.subscribe}`)
            .padding(CommonConstant.SmallContainerInnerPadding)
            .backgroundColor(CommonConstant.ThemeColor)
            .borderRadius(CommonConstant.RadiusSmall)
            .fontColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Medium)
            .fontSize(CommonConstant.TextSizeTiny)
        }
        .width(CommonConstant.FullPercent)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width(CommonConstant.FullPercent)
    }
    .layoutWeight(1)
  }

  build() {
    Row({ space: CommonConstant.NormalContainerInnerPadding }) {
      this.topicIconBuilder()

      this.content()
    }
    .width(CommonConstant.FullPercent)
    .backgroundColor($r('app.color.second_window_background'))
    .padding(CommonConstant.NormalContainerInnerPadding)
    .borderRadius(CommonConstant.RadiusLarge)
    .alignItems(VerticalAlign.Top)
    .justifyContent(FlexAlign.Start)
  }
}