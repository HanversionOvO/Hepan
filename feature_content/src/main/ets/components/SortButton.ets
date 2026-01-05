import { CommonConstant } from 'base_common';
import { TieVM } from '../viewmodels/TieVM';

export interface SortItem {
  id: number;
  idlist: "newreply" | "newthread" | "digest" | "life" | "hotlist" | "allreplies" | "allvisits";
  name: ResourceStr;
  icon: Resource;
}

@ComponentV2
export struct SortButton {
  @Param @Require vm: TieVM;

  @Builder
  SortItemView(item: SortItem, index: number) {
    Row({ space: CommonConstant.SmallContainerInnerPadding }) {
      SymbolGlyph(item.icon)
        .fontSize(CommonConstant.TextSizeSmall)
        .fontWeight(FontWeight.Bold)
        .fontColor([(this.vm.isSorting && this.vm.currentSort === index) ? $r('sys.color.font_on_primary') :
          $r('sys.color.font_primary')]);
      if (this.vm.isSorting || this.vm.isTabletView) {
        Text(item.name)
          .fontSize(CommonConstant.TextSizeSmall)
          .fontWeight(FontWeight.Bold)
          .fontColor((this.vm.isSorting && this.vm.currentSort === index) ? $r('sys.color.font_on_primary') :
            $r('sys.color.font_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .padding({
      left: this.vm.isTabletView || this.vm.isSorting ? CommonConstant.SmallContainerInnerPadding : 0,
      right: this.vm.isTabletView || this.vm.isSorting ? CommonConstant.SmallContainerInnerPadding : 0
    })
    .height(CommonConstant.FullPercent)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .width((!this.vm.isSorting && !this.vm.isTabletView) ? CommonConstant.FullPercent : undefined)
    .backgroundColor((this.vm.isSorting && this.vm.currentSort === index) ? $r('app.color.sub_color') :
      Color.Transparent)
    .borderRadius(CommonConstant.RadiusRound)
    .onClick(() => {
      animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring },
        () => {
          if (this.vm.isSorting) {
            this.vm.currentSort = index;
            this.vm.isSorting = false;
          } else {
            this.vm.isSorting = true;
          }
        })
    })
  }

  build() {
    List({ space: CommonConstant.SmallContainerInnerPadding }) {
      if (this.vm.isSorting) {
        ForEach(this.vm.sortItems, (item: SortItem, index: number) => {
          ListItem() {
            this.SortItemView(item, index)
          }
        }, (item: SortItem) => item.id.toString())
      } else {
        ListItem() {
          if (this.vm.sortItems.length > 0 && this.vm.currentSort < this.vm.sortItems.length) {
            this.SortItemView(this.vm.sortItems[this.vm.currentSort], this.vm.currentSort)
          }
        }
      }
    }
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .height(CommonConstant.IconSizeLarge)
    .padding({
      top: CommonConstant.SmallContainerTBPadding / 2,
      bottom: CommonConstant.SmallContainerTBPadding / 2,
      left: this.vm.isTabletView || this.vm.isSorting ? CommonConstant.SmallContainerTBPadding / 2 : 0,
      right: this.vm.isTabletView || this.vm.isSorting ? CommonConstant.SmallContainerTBPadding / 2 : 0,
    })
    .borderRadius(CommonConstant.RadiusRound)
    .border({ width: CommonConstant.BorderSizeNormal, color: $r('app.color.glass_border') })
    .backgroundColor(Color.Transparent)
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THICK)
    .width((this.vm.isSorting || this.vm.isTabletView) ? undefined : CommonConstant.IconSizeLarge)
    .animation({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring })
    .constraintSize({ maxWidth: this.vm.isTabletView ? undefined : this.vm.window.windowWidth / 2 })
    .clip(true)
  }
}