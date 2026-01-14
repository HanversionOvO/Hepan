import { BaseVM, CommonConstant } from 'base_common';

export interface NavTitleButtonModel {
  color?: ResourceStr,
  icon: Resource,
  geometryID?: string,
  onClick: () => void
}

@ComponentV2
export struct CustomNavTitle {
  @Param @Require vm: BaseVM;
  @Param title: ResourceStr = "";
  @Param bgColor: ResourceColor = $r('app.color.start_window_background');
  @Param contentColor: ResourceColor = $r('sys.color.font_primary');
  @Param buttons: NavTitleButtonModel[] | undefined = undefined;
  @Param enableGlassMode: boolean = false;
  @Param isHideTitle: boolean = false;

  @Builder
  titleButton(navTitleButtonModel: NavTitleButtonModel) {
    Column() {
      SymbolGlyph(navTitleButtonModel.icon)
        .fontSize(CommonConstant.TextSizeUltraLarge)
        .fontWeight(FontWeight.Bold)
        .fontColor([this.contentColor])
        .animation({ duration: CommonConstant.AnimationDurationNormal })
    }
    .width(CommonConstant.IconSizeLarge)
    .height(CommonConstant.IconSizeLarge)
    .borderRadius(CommonConstant.RadiusRound)
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
    .backgroundColor(navTitleButtonModel.color ?? Color.Transparent)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      navTitleButtonModel.onClick();
    })
    .geometryTransition(navTitleButtonModel.geometryID ?? undefined)
    .animation({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring })
    .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.85 })
  }

  build() {
    Row() {
      if (!this.isHideTitle) {
        Row() {
          Text(this.title)
            .fontSize(CommonConstant.TextSizeUltraLarge)
            .fontColor(this.contentColor)
            .fontWeight(FontWeight.Bolder)
            .animation({ duration: CommonConstant.AnimationDurationNormal })
        }
        .margin({
          left: this.enableGlassMode ? CommonConstant.NormalContainerInnerPadding : 0
        })
        .height(CommonConstant.IconSizeLarge + CommonConstant.SmallContainerInnerPadding * 2)
        .alignItems(VerticalAlign.Center)
        .padding({
          left: CommonConstant.PageLRPadding,
          right: CommonConstant.PageLRPadding
        })
        .borderRadius(CommonConstant.RadiusRound)
        .backgroundColor(this.enableGlassMode ? $r('app.color.glass_background') : Color.Transparent)
        .backgroundBlurStyle(this.enableGlassMode ? BlurStyle.BACKGROUND_THICK : BlurStyle.NONE)
        .border(
          this.enableGlassMode
            ? {
            width: CommonConstant.BorderSizeNormal,
            color: $r('app.color.glass_border')
          }
            : {
            width: CommonConstant.BorderSizeNormal,
            color: Color.Transparent
          }
        )
        .hitTestBehavior(HitTestMode.Transparent)
      }

      Blank()
        .layoutWeight(1)
        .hitTestBehavior(HitTestMode.None)

      if (this.buttons) {
        Row({ space: CommonConstant.NormalContainerInnerPadding }) {
          ForEach(this.buttons, (navTitleButtonModel: NavTitleButtonModel) => {
            this.titleButton(navTitleButtonModel);
          })
        }
        .padding({
          right: CommonConstant.PageLRPadding
        })
      }
    }
    .backgroundColor(this.bgColor)
    .height(this.vm.window.windowTopPadding + CommonConstant.TopBarHeight)
    .width(CommonConstant.FullPercent)
    .hitTestBehavior(HitTestMode.None)
    .padding({
      top: this.vm.window.windowTopPadding,
    })
    .animation({ duration: CommonConstant.AnimationDurationNormal })
    .hitTestBehavior(HitTestMode.Transparent)
  }
}