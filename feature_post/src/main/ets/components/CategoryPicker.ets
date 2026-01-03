import { AppUtil } from '@pura/harmony-utils';
import { ColorUtil, CommonConstant, PostCategories } from 'base_common';
import { CustomTabBar } from 'base_ui';
import { PostPageVM } from '../viewmodels/PostPageVM';

@ComponentV2
export struct CategoryPicker {
  @Param @Require vm: PostPageVM;

  private isSubSelected(subName: string): boolean {
    return this.vm.selectedSubCategory === subName;
  }

  // === 二级话题标签 ===
  @Builder
  SubChannelItem(sub: PostCategories) {
    Text('# ' + sub.name)
      .fontSize(CommonConstant.TextSizeTiny)
      .fontColor(this.isSubSelected(sub.name) ? CommonConstant.ThemeColor : $r('sys.color.font_primary'))
      .fontWeight(this.isSubSelected(sub.name) ? FontWeight.Bold : FontWeight.Regular)
      .padding({
        left: CommonConstant.SmallContainerLRPadding,
        right: CommonConstant.SmallContainerLRPadding,
        top: CommonConstant.SmallContainerTBPadding,
        bottom: CommonConstant.SmallContainerTBPadding
      })
      .backgroundColor(this.isSubSelected(sub.name) ? ColorUtil.opacity(CommonConstant.ThemeColor) :
        $r('app.color.second_window_background'))
      .borderRadius(CommonConstant.RadiusSmall)
      .border({
        width: CommonConstant.BorderSizeNormal,
        color: this.isSubSelected(sub.name) ? CommonConstant.ThemeColor : Color.Transparent
      })
      .onClick(() => {
        this.vm.selectedSubCategory = sub.name;
      })
      .margin({ right: CommonConstant.NormalContainerInnerPadding, bottom: CommonConstant.NormalContainerInnerPadding })
  }

  build() {
    Column({ space: CommonConstant.NormalContainerInnerPadding }) {
      Row() {
        Row({ space: CommonConstant.NormalContainerInnerPadding }) {
          SymbolGlyph($r('sys.symbol.list_number'))
            .fontSize(CommonConstant.TextSizeNormal)
            .fontColor([CommonConstant.ThemeColor])
            .animation({ duration: CommonConstant.AnimationDurationNormal })

          Text() {
            Span(this.vm.currentMainCategoryName)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
            Span(' / ')
            Span(this.vm.selectedSubCategory || '全部')
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
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('app.color.start_window_background'))
      .onClick(() => {
        AppUtil.getUIContext()
          .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring },
            () => {
              this.vm.isCategoryExpanded = !this.vm.isCategoryExpanded;
            })
      })

      // === 2. 折叠内容区 ===
      if (this.vm.isCategoryExpanded) {
        Column({ space: CommonConstant.SmallContainerTBPadding }) {
          Row() {
            CustomTabBar({
              tabItems: this.vm.categoryTabs,
              vm: this.vm,
              currentIndex: this.vm.currentCategory,
              tabButtonHeight: CommonConstant.IconSizeLarge,
              alignMode: FlexAlign.Start,
              changeTab: (index) => {
                this.vm.currentCategory = index;
              }
            })
          }
          .width(CommonConstant.FullPercent)

          // B. 二级网格/瀑布流
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            if (this.vm.categories.length > this.vm.currentCategory) {
              ForEach(this.vm.categories[this.vm.currentCategory].children || [], (sub: PostCategories) => {
                this.SubChannelItem(sub)
              })
            }
          }
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
    .padding({
      top: CommonConstant.NormalContainerTBPadding
    })
  }
}