import { ColorUtil, CommonConstant } from "base_common";

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
      .animation({
        duration: CommonConstant.AnimationDurationNormal,
        curve: CommonConstant.AnimationCurveNormal
      })
      .onChange((value) => {
        this.$value(value);
      })
      .onFocus(() => {
        this.bgColor = ColorUtil.lighten(CommonConstant.ThemeColor)
        this.brColor = CommonConstant.ThemeColor
      })
      .onBlur(() => {
        // 失去焦点：恢复默认颜色
        this.brColor = $r('app.color.glass_border');
        this.bgColor = $r('app.color.second_window_background');
      })
  }
}