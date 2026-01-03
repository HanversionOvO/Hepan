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
  @Local richFuc: RichTextButton[] = [
    {
      icon: $r('sys.symbol.bold'), onClick: () => {
      this.vm.applyBold();
    }
    },
    {
      icon: $r('sys.symbol.italic'), onClick: () => {
      this.vm.applyItalic();
    }
    },
    {
      icon: $r('sys.symbol.underline'), onClick: () => {
      this.vm.applyUnderline();
    }
    },
    {
      icon: $r('sys.symbol.strikethrough'), onClick: () => {
      this.vm.applyStrikethrough();
    }
    },
    {
      icon: $r('sys.symbol.list_number'), onClick: () => {
      this.vm.applyOrderedList();
    }
    },
    {
      icon: $r('sys.symbol.list_bullet'), onClick: () => {
      this.vm.applyUnorderedList();
    }
    },
    {
      icon: $r('sys.symbol.line'), onClick: () => {
      this.vm.insertDivider();
    }
    },
    {
      icon: $r('sys.symbol.list_checkmask'), onClick: () => {
      this.vm.applyTaskList();
    }
    },
    {
      icon: $r('sys.symbol.chevron_right'), onClick: () => {
      this.vm.applyQuote();
    }
    }
  ];

  @Builder
  ButtonBuilder(icon: Resource, onClick: () => void) {
    SymbolGlyph(icon)
      .fontSize(CommonConstant.IconSizeNormal)
      .fontColor([$r('sys.color.font_secondary')])
      .onClick(() => {
        onClick();
      })
  }

  build() {
    Stack({ alignContent: this.vm.isTabletView ? Alignment.End : Alignment.Start }) {
      Divider()
        .color($r('sys.color.font_tertiary'))
        .vertical(this.vm.isTabletView)
        .width(this.vm.isTabletView ? CommonConstant.BorderSizeHuge : CommonConstant.FullPercent)
        .height(this.vm.isTabletView ? CommonConstant.FullPercent : CommonConstant.BorderSizeHuge)
        .margin({ bottom: this.vm.isTabletView ? 0 : CommonConstant.TopBarHeight })

      Flex({
        direction: this.vm.isTabletView ? FlexDirection.Column : FlexDirection.Row,
        alignItems: ItemAlign.Center,
        space: {
          main: LengthMetrics.vp(CommonConstant.LargeContainerInnerPadding)
        }
      }) {
        ForEach(this.buttons, (button: RichTextButton, index: number) => {
          this.ButtonBuilder(button.icon, button.onClick)
        }, (button: RichTextButton, index: number) => index.toString())

        Divider()
          .color($r('sys.color.font_secondary'))
          .width(this.vm.isTabletView ? CommonConstant.IconSizeNormal : CommonConstant.BorderSizeLarge)
          .height(this.vm.isTabletView ? CommonConstant.BorderSizeLarge : CommonConstant.IconSizeNormal)
          .vertical(!this.vm.isTabletView)

        List({ space: CommonConstant.NormalContainerInnerPadding }) {
          ForEach(this.richFuc, (button: RichTextButton, index: number) => {
            ListItem() {
              this.ButtonBuilder(button.icon, button.onClick)
            }
          }, (button: RichTextButton, index: number) => index.toString())
        }
        .alignListItem(ListItemAlign.Center)
        .listDirection(this.vm.isTabletView ? Axis.Vertical : Axis.Horizontal)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
      .padding({
        left: this.vm.isTabletView ? 0 : CommonConstant.SmallContainerLRPadding,
        right: this.vm.isTabletView ? 0 : CommonConstant.SmallContainerLRPadding,
      })
    }
    .width(this.vm.isTabletView ? CommonConstant.TopBarHeight : CommonConstant.FullPercent)
    .height(this.vm.isTabletView ? CommonConstant.FullPercent : CommonConstant.TopBarHeight)
  }
}