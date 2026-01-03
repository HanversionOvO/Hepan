import { ColorUtil, CommonConstant } from 'base_common';
import { CustomTabBar } from 'base_ui';
import { PostPageVM } from '../viewmodels/PostPageVM';

@ComponentV2
export struct CategoryPicker {
  @Param @Require vm: PostPageVM;

  private isSubSelected(sub: string): boolean {
    return this.vm.selectedSubCategory === sub;
  }

  // === 二级话题标签 ===
  @Builder
  SubChannelItem(sub: string) {
    Text('# ' + sub)
      .fontSize(CommonConstant.TextSizeSmall)
      .fontColor(this.isSubSelected(sub) ? CommonConstant.ThemeColor : $r('sys.color.font_primary'))
      .fontWeight(this.isSubSelected(sub) ? FontWeight.Bold : FontWeight.Regular)
      .padding({
        left: CommonConstant.SmallContainerLRPadding,
        right: CommonConstant.SmallContainerLRPadding,
        top: CommonConstant.SmallContainerTBPadding,
        bottom: CommonConstant.SmallContainerTBPadding
      })
      .backgroundColor(this.isSubSelected(sub) ? ColorUtil.opacity(CommonConstant.ThemeColor) :
        $r('app.color.second_window_background'))
      .borderRadius(CommonConstant.RadiusSmall)
      .border({
        width: CommonConstant.BorderSizeNormal,
        color: this.isSubSelected(sub) ? CommonConstant.ThemeColor : Color.Transparent
      })
      .onClick(() => {

      })
      .margin({ right: CommonConstant.NormalContainerInnerPadding, bottom: CommonConstant.NormalContainerInnerPadding })
  }

  build() {
    Column() {
      // === 1. 触发栏 ===
      Row() {
        Row({ space: CommonConstant.SmallContainerInnerPadding }) {
          SymbolGlyph($r('sys.symbol.list_number'))
            .fontSize(CommonConstant.TextSizeNormal)
            .fontColor(this.vm.selectedCategory ? [CommonConstant.ThemeColor] : [$r('sys.color.font_secondary')])
            .animation({ duration: CommonConstant.AnimationDurationNormal })


          Text() {
            Span(this.vm.currentMainKey)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
            Span('  /  ')
            Span(this.vm.selectedSubCategory)
              .fontColor($r('sys.color.font_secondary'))
          }
          .fontSize(CommonConstant.TextSizeNormal)
        }

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(CommonConstant.TextSizeSmall)
          .fontColor([$r('sys.color.font_tertiary')])
          .rotate({ angle: this.vm.isCategoryExpanded ? 90 : 0 })
          .animation({ curve: CommonConstant.AnimationCurveSpring, duration: CommonConstant.AnimationDurationNormal })
      }
      .width(CommonConstant.FullPercent)
      .padding({
        left: CommonConstant.PageLRPadding,
        right: CommonConstant.PageLRPadding,
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('app.color.start_window_background'))
      .onClick(() => {
      })

      // === 2. 折叠内容区 ===
      if (this.vm.isCategoryExpanded) {
        Column() {
          Row() {
            CustomTabBar({
              tabItems: this.vm.categoryTabs,
              vm: this.vm,
              currentIndex: this.vm.currentCategory,
              alignMode: FlexAlign.Start, // 左对齐
              changeTab: (index) => {

              }
            })
          }
          .width(CommonConstant.FullPercent)
          .padding({ left: CommonConstant.PageLRPadding, right: CommonConstant.PageLRPadding })

          // B. 二级网格/瀑布流
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.vm.categories[this.vm.currentMainKey], (sub: string) => {
              this.SubChannelItem(sub)
            })
          }
          .padding({ left: CommonConstant.PageLRPadding, right: CommonConstant.PageLRPadding })
          .transition(TransitionEffect.OPACITY.animation({ duration: CommonConstant.AnimationDurationNormal }))
        }
        .width(CommonConstant.FullPercent)
        .backgroundColor($r('app.color.start_window_background'))
        .transition(
          TransitionEffect.OPACITY
            .combine(TransitionEffect.translate({ y: -10 }))
            .combine(TransitionEffect.scale({ y: 0.95 }))
            .animation({ curve: CommonConstant.AnimationCurveSpring })
        )
      }
    }
    .width(CommonConstant.FullPercent)
    .clip(true)
    .animation({ curve: CommonConstant.AnimationCurveSpring })
  }
}