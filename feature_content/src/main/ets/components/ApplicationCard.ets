import { CommonConstant, RouterMap } from 'base_common';
import { ApplicationVM } from '../viewmodels/ApplicationVM';

export interface ApplicationCardItemOptions {
  id: string;
  icon?: Resource;
  iconColor?: ResourceColor;
  name?: ResourceStr;
  desc?: ResourceStr;
  author?: ResourceStr;
  route?: RouterMap;
}

@ObservedV2
export class ApplicationCardItem {
  @Trace id: string = "";
  @Trace icon: Resource = $r('sys.symbol.person');
  @Trace iconColor: ResourceColor = ""; // 建议设置默认颜色或处理空逻辑
  @Trace name: ResourceStr = "";
  @Trace desc: ResourceStr = "";
  @Trace author?: ResourceStr;
  @Trace route: RouterMap = RouterMap.HOME;

  constructor(data?: ApplicationCardItemOptions) {
    if (data) {
      this.id = data.id ?? this.id;
      this.icon = data.icon ?? this.icon;
      this.iconColor = data.iconColor ?? this.iconColor;
      this.name = data.name ?? this.name;
      this.desc = data.desc ?? this.desc;
      this.author = data.author;
      this.route = data.route ?? this.route;
    }
  }
}

@ComponentV2
export struct ApplicationCard {
  @Param @Require application: ApplicationCardItem;
  @Param @Require vm: ApplicationVM;
  @Param @Require context: UIContext;

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
    .animation({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring })
    .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.85 })
  }
}