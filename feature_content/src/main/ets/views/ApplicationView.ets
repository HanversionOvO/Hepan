import { CommonConstant } from 'base_common';

@ComponentV2
export struct ApplicationView {
  build() {
    Stack()
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
  }
}