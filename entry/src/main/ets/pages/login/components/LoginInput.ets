import { ColorUtil, CommonConstant } from "base_common";

@ComponentV2
export struct LoginInput {
  @Param placeHolder: ResourceStr = "";
  @Param isPassword: boolean = false;
  @Local brColor: ResourceColor = $r('app.color.glass_border');
  @Local bgColor: ResourceColor = $r('app.color.second_window_background');

  build() {
    TextInput({
      placeholder: this.placeHolder
    })
      .borderRadius(CommonConstant.RadiusSmall)
      .backgroundColor(this.bgColor)
      .border({ width: CommonConstant.BorderSizeNormal, color: this.brColor })
      .caretColor(CommonConstant.ThemeColor)
      .type(this.isPassword ? InputType.Password : InputType.Normal)
      .onFocus(() => {
        this.bgColor = ColorUtil.lighten(CommonConstant.ThemeColor)
        this.brColor = CommonConstant.ThemeColor
      })
  }
}