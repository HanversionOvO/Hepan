import { CommonConstant } from 'base_common';

@ComponentV2
export struct FloatButton {
  @Param isFloating: boolean = false;
  @Param floatIcon: Resource = $r('sys.symbol.chevron_left');
  @Param floatIconColor: ResourceColor = $r("sys.color.font_primary");
  @Param buttonColor: Color | ResourceStr = Color.Transparent;
  @Param blurStyle: BlurStyle = BlurStyle.BACKGROUND_THIN;

  @Computed
  get buttonBlur(): BlurStyle {
    if (this.blurStyle !== BlurStyle.BACKGROUND_THIN) {
      return this.blurStyle;
    } else {
      if (this.isFloating) {
        return this.blurStyle
      } else {
        return BlurStyle.NONE
      }
    }
  }

  build() {
    Column() {
      SymbolGlyph(this.floatIcon)
        .fontSize(CommonConstant.TextSizeUltraLarge)
        .fontWeight(FontWeight.Bold)
        .fontColor([this.floatIconColor])
    }
    .width(CommonConstant.IconSizeLarge)
    .height(CommonConstant.IconSizeLarge)
    .borderRadius(CommonConstant.RadiusRound)
    .backgroundColor(this.buttonColor)
    .backgroundBlurStyle(this.buttonBlur)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .animation({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring })
    .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.85 })
  }
}