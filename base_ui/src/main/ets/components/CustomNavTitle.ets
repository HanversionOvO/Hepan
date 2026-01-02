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
  }

  build() {
    Row() {
      Text(this.title)
        .fontSize(CommonConstant.TextSizeUltraLarge)
        .fontColor(this.contentColor)
        .fontWeight(FontWeight.Bolder)
        .animation({ duration: CommonConstant.AnimationDurationNormal })

      if (this.buttons) {
        Row({ space: CommonConstant.NormalContainerInnerPadding }) {
          ForEach(this.buttons, (navTitleButtonModel: NavTitleButtonModel) => {
            this.titleButton(navTitleButtonModel);
          })
        }
      }
    }
    .backgroundColor(this.bgColor)
    .height(this.vm.window.windowTopPadding + CommonConstant.TopBarHeight)
    .width(CommonConstant.FullPercent)
    .padding({
      top: this.vm.window.windowTopPadding,
      left: CommonConstant.PageLRPadding,
      right: CommonConstant.PageLRPadding
    })
    .justifyContent(FlexAlign.SpaceBetween)
  }
}