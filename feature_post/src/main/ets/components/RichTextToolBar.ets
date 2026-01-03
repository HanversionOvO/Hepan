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
      // TODO: 加粗
    }
    },
    {
      icon: $r('sys.symbol.italic'), onClick: () => {
      // TODO: 斜体
    }
    },
    {
      icon: $r('sys.symbol.underline'), onClick: () => {
      // TODO: 下划线
    }
    },
    {
      icon: $r('sys.symbol.strikethrough'), onClick: () => {
      // TODO: 删除线
    }
    },
    {
      icon: $r('sys.symbol.list_number'), onClick: () => {
      // TODO: 有序列表
    }
    },
    {
      icon: $r('sys.symbol.list_bullet'), onClick: () => {
      // TODO: 无序列表
    }
    },
    {
      icon: $r('sys.symbol.line'), onClick: () => {
      // TODO: 分割线
    }
    },
    {
      icon: $r('sys.symbol.list_checkmask'), onClick: () => {
      // TODO: 任务列表
    }
    },
    {
      icon: $r('sys.symbol.chevron_right'), onClick: () => {
      // TODO: 引用
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