import { ColorUtil, CommonConstant, PostCategoryGroup, PostCategoryItem, ThreadType, UiState } from 'base_common';
import { StateLayout } from 'base_ui';
import { PostPageVM } from '../viewmodels/PostPageVM';
import { curves } from '@kit.ArkUI';

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
        .height(320) // 固定高度，提供稳定的浏览区域
        .width(CommonConstant.FullPercent)
        .backgroundColor($r('app.color.start_window_background'))
        .transition(
          TransitionEffect.OPACITY
            .combine(TransitionEffect.translate({ y: -20 }))
            .combine(TransitionEffect.scale({ y: 0.98 }))
            .animation({ curve: curves.springMotion(0.5, 0.7) })
        )
      }
    }
    .width(CommonConstant.FullPercent)
    .clip(true)
    .backgroundColor($r('app.color.start_window_background'))
    .borderRadius(CommonConstant.RadiusNormal)
    .margin({ bottom: CommonConstant.NormalContainerInnerPadding })
    .shadow({ radius: 4, color: '#0F000000', offsetY: 2 })
  }

  @Builder
  HeaderBar() {
    Row() {
      Row({ space: 8 }) {
        SymbolGlyph($r('sys.symbol.grid'))
          .fontSize(18)
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
                .fontSize(12)
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
        .fontSize(16)
        .fontColor([$r('sys.color.font_tertiary')])
        .rotate({ angle: this.vm.isCategoryExpanded ? 180 : 0 })
        .animation({ curve: curves.springMotion(), duration: 300 })
    }
    .width(CommonConstant.FullPercent)
    .height(48)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      this.vm.toggleCategoryExpand();
    })
  }

  @Builder
  ThreadTypeBar() {
    Column() {
      Divider().color($r('sys.color.comp_divider')).width(CommonConstant.FullPercent).opacity(0.6)

      Scroll() {
        Row({ space: 8 }) {
          Text('分类')
            .fontSize(10)
            .fontColor($r('sys.color.font_tertiary'))
            .margin({ right: 4 })

          if (this.vm.typesStatus === UiState.LOADING) {
            LoadingProgress().width(16).height(16).color($r('sys.color.font_secondary'))
          } else if (this.vm.threadTypes.length > 0) {
            ForEach(this.vm.threadTypes, (type: ThreadType) => {
              Text(type.name)
                .fontSize(11)
                .fontColor(this.vm.selectedTypeId === type.type_id ? Color.White : $r('sys.color.font_secondary'))
                .fontWeight(this.vm.selectedTypeId === type.type_id ? FontWeight.Medium : FontWeight.Regular)
                .padding({
                  left: 10,
                  right: 10,
                  top: 4,
                  bottom: 4
                })
                .backgroundColor(this.vm.selectedTypeId === type.type_id ? CommonConstant.ThemeColor :
                  $r('app.color.second_window_background'))
                .borderRadius(12)
                .onClick(() => {
                  this.vm.onTypeSelected(type);
                })
                .animation({ duration: 200 })
            })
          } else {
            Text('该板块无分类')
              .fontSize(11)
              .fontColor($r('sys.color.font_tertiary'))
          }
        }
        .padding({
          top: 8,
          bottom: 8,
          left: 16,
          right: 16
        })
        .alignItems(VerticalAlign.Center)
      }
      .scrollBar(BarState.Off)
      .width(CommonConstant.FullPercent)
      .edgeEffect(EdgeEffect.Spring)
    }
    .transition(TransitionEffect.OPACITY.animation({ duration: 200 }))
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
                  .width(3)
                  .height(16)
                  .fill(CommonConstant.ThemeColor)
                  .radius(2)
                  .margin({ right: 4 })
                  .transition(TransitionEffect.OPACITY.animation({ duration: 200 }))
              }
              Text(group.name)
                .fontSize(13)
                .fontColor(this.vm.leftPanelIndex === index ? CommonConstant.ThemeColor : $r('sys.color.font_primary'))
                .fontWeight(this.vm.leftPanelIndex === index ? FontWeight.Bold : FontWeight.Regular)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width(CommonConstant.FullPercent)
            .height(44)
            .padding({ left: this.vm.leftPanelIndex === index ? 8 : 12, right: 4 })
            .backgroundColor(this.vm.leftPanelIndex === index ? $r('app.color.start_window_background') :
              $r('app.color.second_window_background'))
            .animation({ duration: 200 })
          }
          .onClick(() => {
            this.vm.selectLeftPanel(index);
          })
        })
      }
      .width('28%') // 左侧占比较窄
      .height(CommonConstant.FullPercent)
      .backgroundColor($r('app.color.second_window_background'))
      .scrollBar(BarState.Off)

      // === 右侧：二级板块 Grid ===
      Column() {
        Scroll() {
          GridRow({ columns: 2, gutter: 8 }) {
            if (this.vm.categories.length > this.vm.leftPanelIndex) {
              ForEach(this.vm.categories[this.vm.leftPanelIndex].children || [], (item: PostCategoryItem) => {
                GridCol() {
                  this.ForumGridItem(item)
                }
              })
            }
          }
          .padding(12)
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
    .border({ width: { top: 1 }, color: $r('sys.color.comp_divider') })
  }

  @Builder
  ForumGridItem(item: PostCategoryItem) {
    Column() {
      Text(item.name)
        .fontSize(13)
        .fontColor(this.vm.selectedForumId === item.fid ? CommonConstant.ThemeColor : $r('sys.color.font_primary'))
        .fontWeight(this.vm.selectedForumId === item.fid ? FontWeight.Bold : FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Start)
        .width(CommonConstant.FullPercent)

      if (item.parentName) {
        Text(item.parentName)
          .fontSize(10)
          .fontColor($r('sys.color.font_tertiary'))
          .margin({ top: 2 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width(CommonConstant.FullPercent)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding(10)
    .backgroundColor(this.vm.selectedForumId === item.fid ? ColorUtil.opacity(CommonConstant.ThemeColor, 0.08) :
      $r('app.color.second_window_background'))
    .borderRadius(8)
    .border({
      width: 1,
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
        .animation({ duration: 100 })
      },
      normal: {
        .scale({ x: 1, y: 1 })
        .animation({ duration: 200 })
      }
    })
  }
}