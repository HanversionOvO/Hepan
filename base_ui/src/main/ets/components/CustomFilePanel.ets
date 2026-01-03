import { BaseVM, CommonConstant } from 'base_common';

export interface CustomFilePanelItem {
  title: ResourceStr;
  icon: Resource;
  onClick: () => void;
}

@ComponentV2
export struct CustomFilePanel {
  @Param @Require vm: BaseVM;
  @Param @Require items: CustomFilePanelItem[];

  @Builder
  FunctionButton(title: ResourceStr, icon: Resource, onClick: () => void) {
    Column({ space: CommonConstant.NormalContainerInnerPadding }) {
      SymbolGlyph(icon)
        .fontSize(CommonConstant.IconSizeUltraLarge)
        .fontColor([$r('sys.color.font_secondary')])
        .fontWeight(FontWeight.Bold)

      Text(title)
        .fontSize(CommonConstant.TextSizeNormal)
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Medium)
    }
    .padding(CommonConstant.NormalContainerInnerPadding)
    .borderRadius(CommonConstant.RadiusLarge)
    .backgroundColor($r('app.color.start_window_background'))
    .onClick(onClick)
  }

  build() {
    Column({ space: CommonConstant.NormalContainerInnerPadding }) {
      Text($r('app.string.CustomFilePanel_title'))
        .width(CommonConstant.FullPercent)
        .fontSize(CommonConstant.TextSizeUltraLarge)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Start)

      Grid() {
        ForEach(this.items, (item: CustomFilePanelItem) => {
          GridItem() {
            this.FunctionButton(item.title, item.icon, item.onClick)
          }
        }, (item: CustomFilePanelItem) => item.title.toString())
      }
      .columnsTemplate('1fr '.repeat(4))
      .rowsGap(CommonConstant.NormalContainerInnerPadding)
      .columnsGap(CommonConstant.NormalContainerInnerPadding)
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
    }
    .width(CommonConstant.FullPercent)
    .height(this.vm.window.windowHeight * 0.4)
    .backgroundColor($r('app.color.second_window_background'))
    .borderRadius({
      topLeft: CommonConstant.RadiusUltraLarge,
      topRight: CommonConstant.RadiusUltraLarge
    })
    .padding({
      left: CommonConstant.NormalContainerLRPadding,
      right: CommonConstant.NormalContainerLRPadding,
      top: CommonConstant.NormalContainerTBPadding,
      bottom: CommonConstant.NormalContainerTBPadding
    })
  }
}