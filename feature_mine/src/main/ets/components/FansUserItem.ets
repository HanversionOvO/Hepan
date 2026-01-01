import { CommonConstant } from 'base_common';

export enum FansUserItemType {
  CARD,
  LIST
}

@ComponentV2
export struct FansUserItem {
  @Param index: number = 0;
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
          Image($r('sys.symbol.person'))
            .fontSize(CommonConstant.IconSizeLarge)
            .fontColor([$r('sys.color.font_tertiary')])
            .borderRadius(CommonConstants.ComponentRadiusRound)
          Column({ space: CommonConstants.ComponentInnerPadding / 2 }) {
            Text(`用户 ${this.index + 1}`)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            Text("保持热爱，奔赴山海")
              .fontSize(CommonConstants.PageTextSmall)
              .fontColor($r('sys.color.font_secondary'))
            Text("在线")
              .fontSize(CommonConstants.PageTextTiny)
              .fontColor($r('sys.color.font_tertiary'))
          }.alignItems(HorizontalAlign.Start)
        }

        GlassButton({
          text: $r('app.string.subscribed')
        })
      }
      .width("100%")
      .padding(CommonConstants.ComponentWithinPadding)
      .backgroundColor($r('app.color.background_secondary'))
      .borderRadius(CommonConstants.ComponentRadiusNormal)
      .justifyContent(FlexAlign.SpaceBetween)
    }
  }
}