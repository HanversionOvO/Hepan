import { ColorUtil, CommonConstant, PostCategoryGroup, PostCategoryItem, ThreadType } from 'base_common';
import { StateLayout } from 'base_ui';
import { PostPageVM } from '../viewmodels/PostPageVM';

@ComponentV2
export struct CategoryPicker {
  @Param @Require vm: PostPageVM;

  build() {
    Column() {
      // 1. 顶部栏 (显示路径 + 点击展开/收起)
      this.HeaderBar()

      // 2. 主题分类选择条 (仅当已选板块且有分类，并且选择器折叠时显示)
      if (this.vm.selectedForumId && !this.vm.isCategoryExpanded) {
        this.ThreadTypeBar()
      }

      // 3. 折叠的板块选择面板 (左右分栏)
      if (this.vm.isCategoryExpanded) {
        Column() {
          // 使用 StateLayout 管理内容区状态
          StateLayout({
            uiState: this.vm.categoriesStatus, // 绑定 VM 中的 UiState
            content: () => {
              this.CategorySelectorBody()
            },
            onRetry: () => {
              this.vm.startPostPage(); // 重试回调
            }
          })
        }
        .height(240) // 固定高度，提供稳定的浏览区域
        .width(CommonConstant.FullPercent)
        .transition(
          TransitionEffect.OPACITY
            .combine(TransitionEffect.translate({ y: -20 }))
            .combine(TransitionEffect.scale({ y: 0.98 }))
            .animation({ curve: CommonConstant.AnimationCurveSpring, duration: CommonConstant.AnimationDurationNormal })
        )
      }
    }
    .width(CommonConstant.FullPercent)
    .clip(true)
    .borderRadius(CommonConstant.RadiusNormal)
  }

  @Builder
  HeaderBar() {
    Row() {
      Row({ space: CommonConstant.NormalContainerInnerPadding }) {
        SymbolGlyph($r('sys.symbol.grid'))
          .fontSize(CommonConstant.TextSizeNormal)
          .fontColor([CommonConstant.ThemeColor])

        if (!this.vm.selectedForumName) {
          Text('点击选择发布版块')
            .fontSize(CommonConstant.TextSizeNormal)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
        } else {
          // 路径式显示
          Text() {
            Span(this.vm.selectedForumName)
              .fontSize(CommonConstant.TextSizeNormal)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))

            if (this.vm.selectedTypeName) {
              Span('  /  ')
                .fontColor($r('sys.color.font_tertiary'))
                .fontSize(CommonConstant.TextSizeSmall)
              Span(this.vm.selectedTypeName)
                .fontColor(CommonConstant.ThemeColor)
                .fontWeight(FontWeight.Medium)
                .fontSize(CommonConstant.TextSizeSmall)
            }
          }
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .layoutWeight(1)

      // 旋转箭头指示
      SymbolGlyph($r('sys.symbol.chevron_down'))
        .fontSize(CommonConstant.TextSizeNormal)
        .fontColor([$r('sys.color.font_tertiary')])
        .rotate({ angle: this.vm.isCategoryExpanded ? 180 : 0 })
        .animation({ curve: CommonConstant.AnimationCurveSpring, duration: CommonConstant.AnimationDurationNormal })
    }
    .width(CommonConstant.FullPercent)
    .padding(CommonConstant.NormalContainerInnerPadding)
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      this.vm.toggleCategoryExpand();
    })
  }

  @Builder
  ThreadTypeBar() {
    Column() {
      Divider()
        .color($r('sys.color.font_tertiary'))
        .width(CommonConstant.FullPercent)

      Row({ space: CommonConstant.NormalContainerInnerPadding }) {
        Text('分类')
          .fontSize(CommonConstant.TextSizeTiny)
          .fontColor($r('sys.color.font_tertiary'))

        if (this.vm.threadTypes.length > 0) {
          List({ space: CommonConstant.NormalContainerInnerPadding }) {
            ForEach(this.vm.threadTypes, (type: ThreadType) => {
              ListItem() {
                Text(type.name)
                  .fontSize(CommonConstant.TextSizeTiny)
                  .fontColor(this.vm.selectedTypeId === type.type_id ? $r('sys.color.font_on_primary') :
                    $r('sys.color.font_secondary'))
                  .borderRadius(CommonConstant.RadiusRound)
                  .fontWeight(this.vm.selectedTypeId === type.type_id ? FontWeight.Medium : FontWeight.Regular)
                  .backgroundColor(this.vm.selectedTypeId === type.type_id ? CommonConstant.ThemeColor :
                    $r('app.color.second_window_background'))
                  .padding(CommonConstant.SmallContainerInnerPadding)
                  .onClick(() => {
                    this.vm.onTypeSelected(type);
                  })
                  .animation({ duration: CommonConstant.AnimationDurationNormal })
              }
            }, (type: ThreadType) => type.type_id.toString())
          }
          .listDirection(Axis.Horizontal)
          .layoutWeight(1)
          .alignListItem(ListItemAlign.Center)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        } else {
          Text('该板块无分类')
            .fontSize(11)
            .fontColor($r('sys.color.font_tertiary'))
        }
      }
      .height(CommonConstant.IconSizeLarge)
      .padding({
        left: CommonConstant.SmallContainerLRPadding,
        right: CommonConstant.SmallContainerLRPadding
      })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
      .width(CommonConstant.FullPercent)
    }
    .transition(TransitionEffect.OPACITY.animation({ duration: CommonConstant.AnimationDurationNormal }))
  }

  @Builder
  CategorySelectorBody() {
    Row() {
      // === 左侧：一级大区列表 ===
      List() {
        ForEach(this.vm.categories, (group: PostCategoryGroup, index: number) => {
          ListItem() {
            Row() {
              // 选中指示条
              if (this.vm.leftPanelIndex === index) {
                Rect()
                  .width(CommonConstant.BorderSizeLarge)
                  .height(CommonConstant.TextSizeNormal)
                  .fill(CommonConstant.ThemeColor)
                  .margin({ right: CommonConstant.SmallContainerInnerPadding })
                  .transition(TransitionEffect.OPACITY.animation({ duration: CommonConstant.AnimationDurationNormal }))
              }
              Text(group.name)
                .fontSize(CommonConstant.TextSizeNormal)
                .fontColor(this.vm.leftPanelIndex === index ? CommonConstant.ThemeColor : $r('sys.color.font_primary'))
                .fontWeight(this.vm.leftPanelIndex === index ? FontWeight.Bold : FontWeight.Regular)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width(CommonConstant.FullPercent)
            .padding({
              top: CommonConstant.NormalContainerTBPadding,
              bottom: CommonConstant.NormalContainerTBPadding,
              left: CommonConstant.NormalContainerLRPadding
            })
            .backgroundColor(this.vm.leftPanelIndex === index ? $r('app.color.start_window_background') :
              $r('app.color.second_window_background'))
            .animation({ duration: CommonConstant.AnimationDurationNormal })
          }
          .onClick(() => {
            this.vm.selectLeftPanel(index);
          })
        })
      }
      .width(CommonConstant.BelowHalfPercent)
      .height(CommonConstant.FullPercent)
      .backgroundColor($r('app.color.second_window_background'))
      .scrollBar(BarState.Off)

      // === 右侧：二级板块 Grid ===
      Column() {
        Scroll() {
          GridRow({ columns: 2, gutter: CommonConstant.NormalContainerInnerPadding }) {
            if (this.vm.categories.length > this.vm.leftPanelIndex) {
              ForEach(this.vm.categories[this.vm.leftPanelIndex].children || [], (item: PostCategoryItem) => {
                GridCol() {
                  this.ForumGridItem(item)
                }
              })
            }
          }
          .padding(CommonConstant.NormalContainerInnerPadding)
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .width(CommonConstant.FullPercent)
        .height(CommonConstant.FullPercent)
      }
      .layoutWeight(1)
      .backgroundColor($r('app.color.start_window_background'))
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)

    .border({ width: { top: 1 }, color: $r('sys.color.font_tertiary') })
  }

  @Builder
  ForumGridItem(item: PostCategoryItem) {
    Column({ space: CommonConstant.SmallContainerInnerPadding }) {
      Text(item.name)
        .fontSize(CommonConstant.TextSizeSmall)
        .fontColor(this.vm.selectedForumId === item.fid ? CommonConstant.ThemeColor : $r('sys.color.font_primary'))
        .fontWeight(this.vm.selectedForumId === item.fid ? FontWeight.Bold : FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Start)
        .width(CommonConstant.FullPercent)

      if (item.parentName) {
        Text(item.parentName)
          .fontSize(CommonConstant.TextSizeTiny)
          .fontColor($r('sys.color.font_tertiary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width(CommonConstant.FullPercent)
      } else {
        Text(item.name)
          .maxLines(1)
          .fontSize(CommonConstant.TextSizeTiny)
          .opacity(0)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding(CommonConstant.NormalContainerInnerPadding)
    .backgroundColor(this.vm.selectedForumId === item.fid ? ColorUtil.opacity(CommonConstant.ThemeColor, 0.08) :
      $r('app.color.second_window_background'))
    .borderRadius(CommonConstant.RadiusSmall)
    .border({
      width: CommonConstant.BorderSizeNormal,
      color: this.vm.selectedForumId === item.fid ? ColorUtil.opacity(CommonConstant.ThemeColor, 0.3) :
        Color.Transparent
    })
    .onClick(() => {
      this.vm.onForumSelected(item);
    })
    // 点击反馈
    .stateStyles({
      pressed: {
        .scale({ x: 0.96, y: 0.96 })
        .animation({ duration: CommonConstant.AnimationDurationNormal })
      },
      normal: {
        .scale({ x: 1, y: 1 })
        .animation({ duration: CommonConstant.AnimationDurationNormal })
      }
    })
  }
}