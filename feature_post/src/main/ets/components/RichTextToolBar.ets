import { CommonConstant } from 'base_common';
import { PostPageVM } from '../viewmodels/PostPageVM';
import { LengthMetrics } from '@kit.ArkUI';

export interface RichTextButton {
  icon: Resource;
  onClick: () => void;
}

@ComponentV2
export struct RichTextToolBar {
  @Param @Require vm: PostPageVM;
  @Param buttons: RichTextButton[] = [];

  build() {
    Stack({ alignContent: this.vm.isTabletView ? Alignment.End : Alignment.Start }) {
      Divider()
        .color($r('sys.color.font_tertiary'))
        .vertical(this.vm.isTabletView)
        .width(this.vm.isTabletView ? CommonConstant.BorderSizeHuge : CommonConstant.FullPercent)
        .height(this.vm.isTabletView ? CommonConstant.FullPercent : CommonConstant.BorderSizeHuge)

      Flex({
        direction: this.vm.isTabletView ? FlexDirection.Column : FlexDirection.Row,
        alignItems: ItemAlign.Center,
        space: {
          main: LengthMetrics.vp(CommonConstant.LargeContainerInnerPadding)
        }
      }) {
        ForEach(this.buttons, (button: RichTextButton, index: number) => {
          SymbolGlyph(button.icon)
            .fontSize(CommonConstant.IconSizeNormal)
            .fontColor([$r('sys.color.font_secondary')])
            .onClick(() => {
              button.onClick();
            })
        }, (button: RichTextButton, index: number) => index.toString())

        Divider()
          .color($r('sys.color.font_secondary'))
          .width(this.vm.isTabletView ? CommonConstant.IconSizeNormal : CommonConstant.BorderSizeLarge)
          .height(this.vm.isTabletView ? CommonConstant.BorderSizeLarge : CommonConstant.IconSizeNormal)
          .vertical(!this.vm.isTabletView)
      }
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
    }
    .width(this.vm.isTabletView ? CommonConstant.TopBarHeight : CommonConstant.FullPercent)
    .height(this.vm.isTabletView ? CommonConstant.FullPercent : CommonConstant.TopBarHeight)
  }
}