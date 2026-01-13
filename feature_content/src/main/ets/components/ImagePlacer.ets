import { ColorUtil, CommonConstant } from 'base_common';
import { TieContentPageVM } from '../viewmodels/TieContentPageVM';

@ComponentV2
export struct ImagePlacer {
  @Param @Require vm: TieContentPageVM;
  @Param @Require swiperHeight: number;
  @Param placeholderColor: string = CommonConstant.ThemeColor;

  private getPlaceholderGradient(): LinearGradientOptions {
    return ColorUtil.buildDiagonalGradient(this.placeholderColor);
  }

  build() {
    Column({ space: CommonConstant.NormalContainerInnerPadding }) {
      Text($r('app.string.ContentPage_title'))
        .fontSize(CommonConstant.IconSizeUltraLarge)
        .fontColor($r('sys.color.font_on_primary'))
        .opacity(0.5)
        .fontWeight(FontWeight.Bolder)
    }
    .width(CommonConstant.FullPercent)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.placeholderColor)
    .linearGradient(this.getPlaceholderGradient())
    .height(this.swiperHeight)
  }
}
