import { CommonConstant, TransitionMap } from 'base_common';
import { TieVM } from '../viewmodels/TieVM';
import { SubCategoryItem } from './SubCategoryButton';

@ComponentV2
export struct SubCategoryPanel {
  @Param @Require vm: TieVM;

  build() {
    Row() {
      Grid() {
        ForEach(this.vm.subCategoryItems, (item: SubCategoryItem, index: number) => {
          GridItem() {
            Text(item.name)
              .height(CommonConstant.FullPercent)
              .fontSize(CommonConstant.TextSizeSmall)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.vm.currentSubCategory === index ? $r('sys.color.font_on_primary') :
                $r('sys.color.font_primary'))
              .backgroundColor(this.vm.currentSubCategory === index ? $r('app.color.sub_color') :
                Color.Transparent)
              .padding({
                left: CommonConstant.PageLRPadding,
                right: CommonConstant.PageLRPadding,
              })
              .borderRadius(CommonConstant.RadiusRound)
              .textAlign(TextAlign.Center)
              .animation({
                duration: CommonConstant.AnimationDurationNormal,
                curve: CommonConstant.AnimationCurveNormal
              })
              .onClick(() => {
                this.vm.currentSubCategory = index;
              })
          }
          .transition(TransitionEffect.OPACITY.combine(TransitionEffect.translate({ y: 15 }))
            .animation({
              duration: CommonConstant.AnimationDurationNormal,
              curve: CommonConstant.AnimationCurveSpring,
              delay: index * 30
            }))
        }, (item: SubCategoryItem) => `${this.vm.currentCategory}_${item.id}`)
      }
      .rowsTemplate('1fr')
      .layoutWeight(1)
      .height(CommonConstant.FullPercent)
      .scrollBar(BarState.Off)
      .borderRadius(CommonConstant.RadiusRound)
      .clip(true);

      Row() {
        Row({ space: CommonConstant.SmallContainerInnerPadding }) {
          SymbolGlyph($r('sys.symbol.chevron_up'))
            .fontSize(CommonConstant.TextSizeSmall)
            .fontWeight(FontWeight.Bold)
            .fontColor([$r('sys.color.font_primary')]);
          if (this.vm.isTabletView) {
            Text($r('app.string.TieView_hide_sub'))
              .fontSize(CommonConstant.TextSizeSmall)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
          }
        }
        .height(CommonConstant.FullPercent)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .width(this.vm.isTabletView ? undefined : CommonConstant.FullPercent)
      }
      .height(CommonConstant.IconSizeLarge)
      .width(this.vm.isTabletView ? undefined : CommonConstant.IconSizeLarge)
      .padding({
        left: CommonConstant.SmallContainerLRPadding,
        right: CommonConstant.SmallContainerLRPadding
      })
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(Color.Transparent)
      .geometryTransition(TransitionMap.TiePageSubCategory, { follow: true })
      .transition(TransitionEffect.OPACITY.animation({ duration: CommonConstant.AnimationDurationNormal }))
      .onClick(() => {
        animateTo({ curve: CommonConstant.AnimationCurveSpring }, () => {
          this.vm.isSubCategoryExpanded = false;
        })
      })
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.IconSizeLarge)
    .backgroundColor(Color.Transparent)
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THICK)
    .padding(CommonConstant.SmallContainerTBPadding / 2)
    .borderRadius(CommonConstant.RadiusRound)
    .border({ width: CommonConstant.BorderSizeNormal, color: $r('app.color.glass_border') })
    .transition(TransitionEffect.OPACITY.combine(TransitionEffect.translate({ y: -10 }))
      .animation({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring }))
  }
}