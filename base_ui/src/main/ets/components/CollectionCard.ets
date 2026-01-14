import { Collection, ColorUtil, CommonConstant, UserAvatarUtil } from 'base_common';
import { ResUtil } from '@pura/harmony-utils';
import { LengthMetrics } from '@kit.ArkUI';

@ComponentV2
export struct CollectionCard {
  @Param @Require collection: Collection;
  @Local topCardSize: number = 64;

  @Builder
  topicIconBuilder() {
    Stack({ alignContent: Alignment.Center }) {
      // 背景装饰
      Column()
        .width(CommonConstant.FullPercent)
        .height(CommonConstant.FullPercent)
        .backgroundColor(CommonConstant.ThemeColor)
        .opacity(0.1) // 极淡的背景色
        .borderRadius(CommonConstant.RadiusNormal)

      // 左侧装饰条
      Divider()
        .vertical(false)
        .width(CommonConstant.FullPercent)
        .strokeWidth(CommonConstant.BorderSizeHuge) // 顶部装饰条
        .color(CommonConstant.ThemeColor)
        .position({ x: 0, y: 0 })

      Column({ space: CommonConstant.SmallContainerInnerPadding }) {
        Text($r('app.string.CollectionView_topic'))
          .fontSize(CommonConstant.TextSizeTiny)
          .fontColor(CommonConstant.ThemeColor)
          .fontWeight(FontWeight.Medium)
          .opacity(0.8)

        Text(this.collection.collection_nums.toString())
          .fontSize(CommonConstant.TextSizeUltraLarge)
          .fontColor(CommonConstant.ThemeColor)
          .fontWeight(FontWeight.Bold)
      }
    }
    .width(this.topCardSize)
    .height(this.topCardSize)
    .borderRadius(CommonConstant.RadiusNormal)
    .clip(true)
  }

  @Builder
  tag(tagName: string) {
    Text(tagName)
      .padding({
        left: CommonConstant.SmallContainerLRPadding / 2,
        right: CommonConstant.SmallContainerLRPadding / 2,
        top: CommonConstant.SmallContainerTBPadding / 2,
        bottom: CommonConstant.SmallContainerTBPadding / 2
      })
      .fontSize(CommonConstant.TextSizeTiny)
      .backgroundColor($r('app.color.start_window_background'))
      .borderRadius(CommonConstant.RadiusSmall)
      .fontColor($r('sys.color.font_secondary'))
  }

  @Builder
  dataPill(label: string, value: string | number) {
    Row({ space: CommonConstant.SmallContainerInnerPadding }) {
      Text(label)
        .fontSize(CommonConstant.TextSizeTiny)
        .fontColor(CommonConstant.ThemeColor)
      Text(value.toString())
        .fontSize(CommonConstant.TextSizeTiny)
        .fontWeight(FontWeight.Medium)
        .fontColor(CommonConstant.ThemeColor)
    }
    .padding({
      left: CommonConstant.SmallContainerLRPadding / 2,
      right: CommonConstant.SmallContainerLRPadding / 2,
      top: CommonConstant.SmallContainerTBPadding / 2,
      bottom: CommonConstant.SmallContainerTBPadding / 2
    })
    .backgroundColor(ColorUtil.opacity(CommonConstant.ThemeColor, 0.1))
    .borderRadius(CommonConstant.RadiusSmall)
  }

  @Builder
  content() {
    Column({ space: CommonConstant.LargeContainerInnerPadding }) {
      Column({ space: CommonConstant.SmallContainerTBPadding }) {
        Row({ space: CommonConstant.NormalContainerInnerPadding }) {
          Text(this.collection.title)
            .fontSize(CommonConstant.TextSizeNormal)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          // 新增：更新时间
          Text(this.collection.lastUpdate)
            .fontSize(CommonConstant.TextSizeTiny)
            .fontColor($r('sys.color.font_tertiary'))
        }
        .width(CommonConstant.FullPercent)
        .alignItems(VerticalAlign.Center)

        // 第二行：描述
        Text(this.collection.description)
          .width(CommonConstant.FullPercent)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor($r('sys.color.font_secondary'))
          .fontSize(CommonConstant.TextSizeSmall)

        if (this.collection.tags && this.collection.tags.length > 0) {
          Flex({
            wrap: FlexWrap.Wrap, space: {
              main: LengthMetrics.vp(CommonConstant.SmallContainerInnerPadding),
              cross: LengthMetrics.vp(CommonConstant.SmallContainerInnerPadding)
            }
          }) {
            ForEach(this.collection.tags, (tag: string) => {
              this.tag(tag)
            }, (tag: string, index: number) => `${tag}_${index}`)
          }
          .width(CommonConstant.FullPercent)
        }
      }
      .width(CommonConstant.FullPercent)

      // 第四行：底部信息（用户 + 数据）
      Row() {
        // 左侧：用户信息
        Row({ space: CommonConstant.SmallContainerInnerPadding }) {
          Image(UserAvatarUtil.getAvatarUrl(this.collection.creator.uid))
            .width(CommonConstant.IconSizeTiny)
            .height(CommonConstant.IconSizeTiny)
            .borderRadius(CommonConstant.RadiusRound)
            .objectFit(ImageFit.Cover)

          Text(this.collection.creator.username)
            .fontSize(CommonConstant.TextSizeSmall)
            .fontColor($r('sys.color.font_secondary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)

        // 右侧：数据统计
        Row({ space: CommonConstant.SmallContainerInnerPadding }) {
          this.dataPill(ResUtil.getStringSync($r('app.string.CollectionView_subs')), this.collection.subscribe)
          this.dataPill(ResUtil.getStringSync($r('app.string.CollectionView_comment')), this.collection.comment)
        }
      }
      .width(CommonConstant.FullPercent)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
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
    .padding(CommonConstant.NormalContainerInnerPadding) // 稍微增加内边距
    .borderRadius(CommonConstant.RadiusLarge)
    .alignItems(VerticalAlign.Top)
    .animation({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring })
    .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.85 })
  }
}
