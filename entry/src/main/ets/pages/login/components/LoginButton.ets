import { CommonConstant } from "base_common";

@ComponentV2
export struct LoginButton {
  build() {
    Button($r('app.string.Login_login_button'))
      .borderRadius(CommonConstant.RadiusSmall)
      .width(CommonConstant.FullPercent)
      .fontColor($r('sys.color.font_on_primary'))
      .backgroundColor(CommonConstant.ThemeColor)
      .fontSize(CommonConstant.TextSizeNormal)
      .fontWeight(FontWeight.Bold)
      .padding({
        top: CommonConstant.NormalContainerTBPadding,
        bottom: CommonConstant.NormalContainerTBPadding,
      })
  }
}