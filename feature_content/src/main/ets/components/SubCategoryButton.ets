import { CommonConstant, TransitionMap } from 'base_common';
import { TieVM } from '../viewmodels/TieVM';

export interface SubCategoryItem {
  fid: number;
  name: ResourceStr
}

@ComponentV2
export struct SubCategoryButton {
  @Param @Require vm: TieVM;

  build() {
    Row() {
      Row({ space: CommonConstant.SmallContainerInnerPadding }) {
        SymbolGlyph($r('sys.symbol.grid'))
          .fontSize(CommonConstant.TextSizeSmall)
          .fontWeight(FontWeight.Bold)
          .fontColor([$r('sys.color.font_primary')]);
        if (this.vm.isTabletView) {
          Text(this.vm.subCategoryItems[this.vm.currentSubCategory]?.name || "")
            .fontSize(CommonConstant.TextSizeSmall)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .key(`${this.vm.currentCategory}_${this.vm.currentSubCategory}`)
        }
      }
      .height(CommonConstant.FullPercent)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .padding({
        left: this.vm.isTabletView ? CommonConstant.SmallContainerInnerPadding : 0,
        right: this.vm.isTabletView ? CommonConstant.SmallContainerInnerPadding : 0
      })
      .width(this.vm.isTabletView ? undefined : CommonConstant.FullPercent)
    }
    .height(CommonConstant.IconSizeLarge)
    .padding({
      left: this.vm.isTabletView ? CommonConstant.SmallContainerInnerPadding : 0,
      right: this.vm.isTabletView ? CommonConstant.SmallContainerInnerPadding : 0,
    })
    .width(this.vm.isTabletView ? undefined : CommonConstant.IconSizeLarge)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .borderRadius(CommonConstant.RadiusRound)
    .border({ width: CommonConstant.BorderSizeNormal, color: $r('app.color.glass_border') })
    .backgroundColor(Color.Transparent)
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THICK)
    .geometryTransition(TransitionMap.TiePageSubCategory, { follow: true })
    .onClick(() => {
      animateTo({ curve: CommonConstant.AnimationCurveSpring }, () => {
        this.vm.isSubCategoryExpanded = true;
      })
    })
  }
}