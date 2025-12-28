import { ColorUtil, CommonConstant } from 'base_common';

@ComponentV2
export struct LoginInput {
  @Param placeHolder: ResourceStr = "";
  @Param isPassword: boolean = false;
  @Param value: string = "";
  @Local brColor: ResourceColor = $r('app.color.glass_border');
  @Local bgColor: ResourceColor = $r('app.color.second_window_background');
  @Event $value: (val: string) => void = (val) => {
  };

  build() {
    TextInput({
      placeholder: this.placeHolder,
      text: this.value
    })
      .borderRadius(CommonConstant.RadiusSmall)
      .backgroundColor(this.bgColor)
      .border({ width: CommonConstant.BorderSizeLarge, color: this.brColor })
      .caretColor(CommonConstant.ThemeColor)
      .type(this.isPassword ? InputType.Password : InputType.Normal)
      .width(CommonConstant.FullPercent)
      .onChange((value) => {
        this.$value(value);
      })
      .onFocus(() => {
        // [修复]：使用 animateTo 仅针对颜色变化应用动画
        animateTo({
          duration: CommonConstant.AnimationDurationNormal,
          curve: CommonConstant.AnimationCurveNormal
        }, () => {
          this.bgColor = ColorUtil.opacity(CommonConstant.ThemeColor);
          this.brColor = CommonConstant.ThemeColor;
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
        })
      })
  }
}