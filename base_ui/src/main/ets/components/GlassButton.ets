import { CommonConstant } from 'base_common';

@ComponentV2
export struct GlassButton {
  @Param text: ResourceStr | undefined = undefined; // 按钮文字
  @Param symbol: Resource | undefined = undefined; // 按钮图标
  @Param innerFontSize: number = CommonConstant.TextSizeNormal; // 文字大小
  @Param innerFontWeight: FontWeight | number = FontWeight.Normal;
  @Param innerFontColor: ResourceStr = $r('sys.color.font_secondary');
  @Param enablePressedDownAnimation: boolean = true;
  @Local scaleValue: number = 1;

  build() {
    Button() {
      Row({ space: CommonConstant.SmallContainerInnerPadding }) {
        if (this.symbol) {
          SymbolGlyph(this.symbol)
            .fontSize(this.innerFontSize)
            .fontColor([this.innerFontColor])
            .fontWeight(this.innerFontWeight)
        }

        if (this.text) {
          Text(this.text)
            .fontSize(this.innerFontSize)
            .fontColor(this.innerFontColor)
            .fontWeight(this.innerFontWeight)
        }
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .padding({
        left: CommonConstant.SmallContainerLRPadding,
        right: CommonConstant.SmallContainerLRPadding,
        top: CommonConstant.SmallContainerTBPadding,
        bottom: CommonConstant.SmallContainerTBPadding
      })
    }
    .backgroundColor($r('app.color.glass_background'))
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THICK)
    .border({ width: CommonConstant.BorderSizeSmall, color: $r('app.color.glass_border') })
    .borderRadius(CommonConstant.RadiusRound)
    .animation({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveNormal })
    .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.85 })
  }
}