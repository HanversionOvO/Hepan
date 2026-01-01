import { MinePageVM } from '../viewmodels/MinePageVM';
import { LengthMetrics } from '@kit.ArkUI';
import { CommonConstant } from 'base_common';

export enum CardType {
  NORMAL_CARD,
  LV_CARD
}

export interface FeatureCardModel {
  cardIcon: Resource;
  cardTitle: ResourceStr;
  cardCount: number;
  // 新增：点击回调
  onClick?: () => void;
}

@ComponentV2
export struct FeatureCard {
  @Param @Require vm: MinePageVM;
  @Param model: FeatureCardModel | undefined = undefined;
  @Param cardType: CardType = CardType.NORMAL_CARD;
  @Param cardHeight: Length = 70;

  @Computed
  get smallCardHeight(): Length {
    if (this.vm.isTabletView) {
      return 120;
    } else {
      return this.cardHeight;
    }
  }

  @Computed
  get smallCardWidth(): Length | undefined {
    if (this.vm.isTabletView) {
      return 140;
    } else {
      return undefined;
    }
  }

  build() {
    Column() {
      if (this.cardType === CardType.NORMAL_CARD && this.model) {
        Flex({
          direction: this.vm.isTabletView ? FlexDirection.Row : FlexDirection.Column,
          space: {
            main: LengthMetrics.vp(CommonConstant.SmallContainerInnerPadding)
          },
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.Center
        }) {
          SymbolGlyph(this.model.cardIcon)
            .fontColor([$r('sys.color.font_secondary')])
            .fontSize(CommonConstant.TextSizeUltraLarge)

          Column({ space: CommonConstant.SmallContainerInnerPadding }) {
            if (this.vm.isTabletView) {
              Text(this.model.cardTitle)
                .fontSize(CommonConstant.TextSizeNormal)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('sys.color.font_secondary'))
            }
            Text(this.model.cardCount.toString())
              .fontSize(CommonConstant.TextSizeNormal)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_secondary'))
          }
          .alignItems(HorizontalAlign.Start)
        }
        .width(CommonConstant.FullPercent)
        .height(CommonConstant.FullPercent)
      } else if (this.cardType === CardType.LV_CARD) {
        Column({ space: CommonConstant.NormalContainerInnerPadding }) {
          // 使用 Stack 将等级文字叠加在进度环中间
          Stack({ alignContent: Alignment.Center }) {
            // 进度环
            Progress({
              value: 50, // 这里可以换成实际经验百分比
              total: 100,
              type: ProgressType.Ring
            })
              .width(this.vm.isTabletView ? CommonConstant.AboveHalfPercent : undefined)
              .height(this.vm.isTabletView ? undefined : CommonConstant.AboveHalfPercent)
              .style({ strokeWidth: CommonConstant.BorderSizeHuge, enableSmoothEffect: true })
              .color(CommonConstant.ThemeColor) // 进度条颜色
              .backgroundColor($r('sys.color.font_on_primary')) // 底色

            // 中间的等级文字
            Column() {
              Text($r('app.string.MinePage_level'))
                .fontSize(CommonConstant.TextSizeSmall)
                .fontColor($r('sys.color.font_secondary'))
              Text(this.vm.user?.user_summary?.level_id.toString()) // 显示等级
                .fontSize(CommonConstant.TextSizeNormal)
                .fontWeight(FontWeight.Bolder)
                .fontColor($r('sys.color.font_secondary'))
              if (this.vm.isTabletView) {
                Text(`50 / 100`)
                  .fontSize(CommonConstant.TextSizeTiny)
                  .fontColor($r('sys.color.font_secondary'))
              }
            }
            .justifyContent(FlexAlign.Center)
          }
        }
        .justifyContent(FlexAlign.Center)
        .width(CommonConstant.FullPercent)
        .height(CommonConstant.FullPercent)
      }
    }
    .height(this.smallCardHeight)
    .width(this.smallCardWidth)
    .layoutWeight(this.vm.isTabletView ? undefined : 1)
    .backgroundColor($r('app.color.glass_background'))
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THICK)
    .border({ width: CommonConstant.BorderSizeNormal, color: $r('app.color.glass_border') })
    .borderRadius(CommonConstant.RadiusNormal)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    // 新增：点击事件绑定
    .onClick(() => {
      if (this.model && this.model.onClick) {
        this.model.onClick();
      }
    })
  }
}