import { Collection, ColorUtil, CommonConstant } from 'base_common';

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

  build() {
    Row({ space: CommonConstant.NormalContainerInnerPadding }) {
      this.topicIconBuilder()
    }
    .width(CommonConstant.FullPercent)
    .backgroundColor($r('app.color.second_window_background'))
    .padding(CommonConstant.NormalContainerInnerPadding)
    .borderRadius(CommonConstant.RadiusLarge)
    .alignItems(VerticalAlign.Top)
    .justifyContent(FlexAlign.Start)
  }
}