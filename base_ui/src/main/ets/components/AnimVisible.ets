import { CommonConstant } from 'base_common';

@ComponentV2
export struct AnimVisible {
  @BuilderParam content: () => void;
  @Param visible: boolean = true; // 控制显隐
  @Param effect: TransitionEffect = CommonConstant.CONF_TRANSITION;

  build() {
    if (this.visible) {
      Column() {
        this.content()
      }
      .transition(this.effect)
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
    }
  }
}