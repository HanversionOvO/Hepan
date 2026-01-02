import { CommonConstant } from 'base_common';

@ComponentV2
export struct CustomSearch {
  @Param placeHolder: string = '';
  @Param searchHeight: number = CommonConstant.IconSizeLarge;
  @Param fontSize: number = CommonConstant.TextSizeSmall;
  @Param searchKey: string = "common_search_input";
  @Param geometryId: string = "default";
  @Event onSubmit: (value: string) => void = () => {
  };

  build() {
    Search({ placeholder: this.placeHolder })
      .id(this.searchKey)
      .textFont({ size: this.fontSize })
      .width(CommonConstant.FullPercent)
      .height(this.searchHeight)
      .placeholderFont({ size: this.fontSize })
      .geometryTransition(this.geometryId)
      .transition(TransitionEffect.OPACITY.animation({
        duration: CommonConstant.AnimationDurationNormal,
        curve: CommonConstant.AnimationCurveNormal
      }))
      .caretStyle({ color: CommonConstant.ThemeColor })
      .searchButton($r('app.string.CustomSearch_search'),
        { fontSize: this.fontSize, fontColor: CommonConstant.ThemeColor })
      .onSubmit((value) => {
        this.onSubmit(value);
      })
  }
}