import { RandomUtil } from '@pura/harmony-utils';
import { CommonConstant } from 'base_common';
import { TieContentPageVM } from '../viewmodels/TieContentPageVM';

@ComponentV2
export struct ImagePlacer {
  @Param @Require vm: TieContentPageVM;
  @Param @Require swiperHeight: number;

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
    .backgroundColor(RandomUtil.getRandomColor())
    .height(this.swiperHeight)
  }
}