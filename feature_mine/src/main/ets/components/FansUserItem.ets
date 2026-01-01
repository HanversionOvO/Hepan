import { CommonConstant, DateUtil } from 'base_common';
import { CustomBadge } from 'base_ui';

export enum FansUserItemType {
  CARD,
  LIST
}

export interface FansUserItems {
  uid: number;
  username: string;
  signature?: ResourceStr;
  avatar: string;
  level?: string;
  date: number;
}

@ComponentV2
export struct FansUserItem {
  @Param @Require user: FansUserItems;
  @Param type: FansUserItemType = FansUserItemType.LIST; // 卡片样式 或 列表样式

  build() {
    if (this.type === FansUserItemType.CARD) {
      // === 横向推荐卡片样式 ===
      // Column({ space: CommonConstants.ComponentWithinPadding }) {
      //   SymbolGlyph($r('sys.symbol.person'))
      //     .fontSize(this.avatarSize)
      //     .fontColor([$r('sys.color.font_tertiary')])
      //     .borderRadius(CommonConstants.ComponentRadiusRound)
      //   Column({ space: CommonConstants.ComponentInnerPadding / 2 }) {
      //     Text(`用户 ${this.index + 1}`)
      //       .fontWeight(FontWeight.Medium)
      //       .fontColor($r('sys.color.font_primary'))
      //       .fontSize(CommonConstants.PageTextNormal)
      //     Text($r('app.string.might_interested'))
      //       .fontSize(CommonConstants.PageTextSmall)
      //       .fontColor($r('sys.color.font_tertiary'))
      //   }
      //
      //   Button($r('app.string.subscribe'))
      //     .backgroundColor($r('app.color.brand_color'))
      //     .fontColor($r('sys.color.font_on_primary'))
      //     .fontWeight(FontWeight.Bold)
      //     .width("100%")
      //     .height(32)
      //     .fontSize(CommonConstants.PageTextNormal)
      // }
      // .borderRadius(CommonConstants.ComponentRadiusNormal)
      // .width(this.listCardSize)
      // .alignItems(HorizontalAlign.Center)
      // .justifyContent(FlexAlign.Center)
      // .backgroundColor($r('app.color.background_secondary'))
      // .padding(CommonConstants.ComponentWithinPadding)
    } else {
      Row() {
        Row({ space: CommonConstant.NormalContainerInnerPadding }) {
          Image(this.user.avatar)
            .height(CommonConstant.IconSizeLarge)
            .width(CommonConstant.IconSizeLarge)
            .borderRadius(CommonConstant.RadiusRound)
            .border({ width: CommonConstant.BorderSizeNormal, color: $r('app.color.glass_border') })
          Column({ space: CommonConstant.SmallContainerInnerPadding }) {
            Row({ space: CommonConstant.NormalContainerInnerPadding }) {
              Text(this.user.username)
                .fontWeight(FontWeight.Medium)
                .fontSize(CommonConstant.TextSizeNormal)
                .fontColor($r('sys.color.font_primary'))

              if (this.user.level) {
                CustomBadge({
                  text: this.user.level,
                  fontSize: CommonConstant.TextSizeUltraTiny,
                  bgColor: CommonConstant.ThemeColor,
                  textColor: $r('sys.color.font_on_primary'),
                  badgeBorderRadius: CommonConstant.RadiusTiny,
                  paddingLR: CommonConstant.SmallContainerInnerPadding,
                  paddingTB: CommonConstant.SmallContainerInnerPadding
                })
              }
            }

            if (this.user.signature) {
              Text(this.user.signature)
                .fontSize(CommonConstant.TextSizeNormal)
                .fontColor($r('sys.color.font_secondary'))
                .maxLines(1)
            }

            Text(DateUtil.getRelativeTime(this.user.date))
              .fontSize(CommonConstant.TextSizeSmall)
              .fontColor($r('sys.color.font_tertiary'))
          }.alignItems(HorizontalAlign.Start)
        }
      }
      .width(CommonConstant.FullPercent)
      .padding({
        left: CommonConstant.NormalContainerLRPadding,
        right: CommonConstant.NormalContainerLRPadding,
        top: CommonConstant.NormalContainerTBPadding,
        bottom: CommonConstant.NormalContainerTBPadding,
      })
      .backgroundColor($r('app.color.second_window_background'))
      .borderRadius(CommonConstant.RadiusLarge)
      .justifyContent(FlexAlign.Start)
    }
  }
}