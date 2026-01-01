import { CommonConstant } from 'base_common';

@ComponentV2
export struct CustomBadge {
  @Param text: string | Resource = "";
  @Param icon: Resource | undefined = undefined;
  @Param textColor: ResourceColor = Color.White;
  @Param bgColor: ResourceColor = Color.Transparent;
  @Param blurStyle: BlurStyle | undefined = undefined;
  @Param badgeBorderWidth: number = 0;
  @Param badgeBorderColor: ResourceColor = Color.Transparent;
  @Param badgeBorderRadius: Length = CommonConstant.RadiusRound;
  @Param paddingLR: Length = CommonConstant.SmallContainerLRPadding;
  @Param paddingTB: Length = CommonConstant.SmallContainerTBPadding;
  @Param fontSize: number = CommonConstant.TextSizeTiny;
  @Param fontWeight: FontWeight = FontWeight.Bold;

  build() {
    Row({ space: CommonConstant.SmallContainerInnerPadding }) {
      if (this.icon) {
        SymbolGlyph(this.icon)
          .fontSize(this.fontSize)
          .fontColor([this.textColor])
      }
      Text(this.text)
        .fontSize(this.fontSize)
        .fontWeight(this.fontWeight)
        .fontColor(this.textColor)
    }
    .padding({
      left: this.paddingLR,
      right: this.paddingLR,
      top: this.paddingTB,
      bottom: this.paddingTB
    })
    .backgroundColor(this.bgColor)
    .borderRadius(this.badgeBorderRadius)
    .border({ width: this.badgeBorderWidth, color: this.badgeBorderColor })
    .backgroundBlurStyle(this.blurStyle)
  }
}