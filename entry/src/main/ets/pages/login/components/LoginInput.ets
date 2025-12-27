import { CommonConstant } from "base_common";

@ComponentV2
export struct LoginInput {
  build() {
    TextInput()
      .borderRadius(CommonConstant.RadiusSmall)
      .backgroundColor($r('app.color.second_window_background'))
  }
}