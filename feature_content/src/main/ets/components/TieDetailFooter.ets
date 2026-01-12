import { ColorUtil, CommonConstant } from 'base_common';
import { TieContentPageVM } from '../viewmodels/TieContentPageVM';

@ComponentV2
export struct TieDetailFooter {
  @Param @Require vm: TieContentPageVM;

  @Builder
  FooterIcon(icon: Resource, value: number | string) {
    Row({ space: CommonConstant.SmallContainerInnerPadding }) {
      SymbolGlyph(icon)
        .fontSize(CommonConstant.TextSizeSmall)
        .fontColor([$r('sys.color.font_secondary')])

      Text(value.toString())
        .fontSize(CommonConstant.TextSizeSmall)
        .fontColor($r('sys.color.font_secondary'))
    }
  }

  build() {
    Row() {
      Row({ space: CommonConstant.SmallContainerInnerPadding }) {
        SymbolGlyph($r('sys.symbol.list_number'))
          .fontSize(CommonConstant.TextSizeSmall)
          .fontColor([CommonConstant.ThemeColor])
          .padding(CommonConstant.SmallContainerInnerPadding)
          .backgroundColor(ColorUtil.opacity(CommonConstant.ThemeColor))
          .borderRadius(CommonConstant.RadiusRound)

        Text(this.vm.forumName)
          .fontSize(CommonConstant.TextSizeSmall)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
      }
      .borderRadius(CommonConstant.RadiusRound)
      .padding(CommonConstant.SmallContainerInnerPadding)
      .backgroundColor($r('app.color.second_window_background'))

      Row({ space: CommonConstant.NormalContainerInnerPadding }) {
        this.FooterIcon($r('sys.symbol.eye'), this.vm.tieThread.views ?? 0)
        this.FooterIcon($r('sys.symbol.heart'), this.vm.tieTopic?.support ?? 0)
      }
    }
    .width(CommonConstant.FullPercent)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}
