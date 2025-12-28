import { ColorUtil, CommonConstant } from 'base_common';

@ComponentV2
export struct LoginInput {
  @Param placeHolder: ResourceStr = "";
  @Param isPassword: boolean = false;
  @Param value: string = "";
  @Param icon: Resource | undefined = undefined;
  @Local brColor: ResourceColor = $r('app.color.glass_border');
  @Local textColor: ResourceColor = $r('sys.color.font_primary');
  @Local iconColor: ResourceColor = $r('sys.color.font_secondary');
  @Local bgColor: ResourceColor = $r('app.color.second_window_background');
  @Event $value: (val: string) => void = (val) => {
  };

  build() {
    Row({ space: CommonConstant.SmallContainerInnerPadding }) {
      if (this.icon) {
        SymbolGlyph(this.icon)
          .fontSize(CommonConstant.TextSizeNormal)
          .fontColor([this.iconColor])
          .animation({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveNormal })
          .fontWeight(FontWeight.Bold)
      }

      TextInput({
        placeholder: this.placeHolder,
        text: this.value
      })
        .fontSize(CommonConstant.TextSizeNormal)
        .placeholderFont({ size: CommonConstant.TextSizeNormal })
        .placeholderColor(this.iconColor)
        .caretColor(CommonConstant.ThemeColor)
        .type(this.isPassword ? InputType.Password : InputType.Normal)
        .layoutWeight(1)
        .borderRadius(0)
        .backgroundColor(Color.Transparent)
        .onChange((value) => {
          this.$value(value);
        })
        .onFocus(() => {
          // [修复]：使用 animateTo 仅针对颜色变化应用动画
          animateTo({
            duration: CommonConstant.AnimationDurationNormal,
            curve: CommonConstant.AnimationCurveNormal
          }, () => {
            this.bgColor = ColorUtil.opacity(CommonConstant.ThemeColor, 0.4);
            this.brColor = CommonConstant.ThemeColor;
            this.iconColor = CommonConstant.ThemeColor;
          })
        })
        .onBlur(() => {
          // [修复]：失去焦点恢复默认颜色
          animateTo({
            duration: CommonConstant.AnimationDurationNormal,
            curve: CommonConstant.AnimationCurveNormal
          }, () => {
            this.brColor = $r('app.color.glass_border');
            this.bgColor = $r('app.color.second_window_background');
            this.iconColor = $r('sys.color.font_secondary');
          })
        })
    }
    .width(CommonConstant.FullPercent)
    .borderRadius(CommonConstant.RadiusSmall)
    .backgroundColor(this.bgColor)
    .border({ width: CommonConstant.BorderSizeLarge, color: this.brColor })
    .padding({
      left: CommonConstant.SmallContainerLRPadding,
      right: CommonConstant.SmallContainerLRPadding
    })
  }
}