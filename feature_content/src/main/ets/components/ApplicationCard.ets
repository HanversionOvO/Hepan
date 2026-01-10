import { CommonConstant } from 'base_common';

export interface ApplicationCardItemOptions {
  icon?: Resource;
  iconColor?: ResourceColor;
  name?: ResourceStr;
  desc?: ResourceStr;
  author?: ResourceStr;
  onClick?: () => void;
}

@ObservedV2
export class ApplicationCardItem {
  @Trace icon: Resource = $r('sys.symbol.person');
  @Trace iconColor: ResourceColor = ""; // 建议设置默认颜色或处理空逻辑
  @Trace name: ResourceStr = "";
  @Trace desc: ResourceStr = "";
  @Trace author?: ResourceStr;
  @Trace onClick?: () => void;

  constructor(data?: ApplicationCardItemOptions) {
    if (data) {
      // 使用空值合并运算符 ?? 只有当 data.icon 为 undefined/null 时才使用默认值
      this.icon = data.icon ?? this.icon;
      this.iconColor = data.iconColor ?? this.iconColor;
      this.name = data.name ?? this.name;
      this.desc = data.desc ?? this.desc;
      this.author = data.author;
      this.onClick = data.onClick;
    }
  }
}

@ComponentV2
export struct ApplicationCard {
  @Param @Require application: ApplicationCardItem;

  build() {
    Row({ space: CommonConstant.NormalContainerInnerPadding }) {
      Row() {
        SymbolGlyph(this.application.icon)
          .fontSize(CommonConstant.TextSizeLarge)
          .fontColor([$r('sys.color.font_on_primary')])
          .fontWeight(FontWeight.Bold)
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .width(CommonConstant.IconSizeLarge)
      .height(CommonConstant.IconSizeLarge)
      .backgroundColor(this.application.iconColor)
      .borderRadius(CommonConstant.RadiusNormal)

      Column({ space: CommonConstant.SmallContainerInnerPadding }) {
        Text(this.application.name)
          .fontSize(CommonConstant.TextSizeNormal)
          .fontWeight(FontWeight.Medium)

        Text(this.application.desc)
          .fontSize(CommonConstant.TextSizeSmall)
          .fontColor($r('sys.color.font_secondary'))
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (this.application.author) {
          Text(this.application.author)
            .fontSize(CommonConstant.TextSizeTiny)
            .fontColor($r('sys.color.font_tertiary'))
        }
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width(CommonConstant.FullPercent)
    .borderRadius(CommonConstant.RadiusLarge)
    .padding({
      left: CommonConstant.NormalContainerLRPadding,
      right: CommonConstant.NormalContainerLRPadding,
      top: CommonConstant.NormalContainerTBPadding,
      bottom: CommonConstant.NormalContainerTBPadding
    })
    .alignItems(VerticalAlign.Top)
    .backgroundColor($r('app.color.second_window_background'))
    .onClick(() => {
      if (this.application.onClick) {
        this.application.onClick();
      }
    })
  }
}