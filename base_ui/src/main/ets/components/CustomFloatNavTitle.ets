import { BaseVM, CommonConstant, RouterUtil } from 'base_common';
import { FloatButton } from '../../../../Index';
import { NavTitleButtonModel } from './CustomNavTitle';

@ComponentV2
export struct CustomFloatNavTitle {
  @Param @Require vm: BaseVM;
  @Param isFloating: boolean = false;
  @Param buttons: NavTitleButtonModel[] | undefined = undefined;
  @Param bgColor: ResourceColor = $r('app.color.second_window_background');
  @Param iconColor: ResourceColor = $r('sys.color.font_primary');
  @Param isContentCenter: boolean = false;
  @BuilderParam content: () => void = this.defaultBuilder;
  @Event onBackClicked: () => void = () => {
    RouterUtil.pop()
  };

  @Builder
  defaultBuilder() {
  }

  build() {
    Row({ space: CommonConstant.NormalContainerInnerPadding }) {
      FloatButton({
        isFloating: this.isFloating,
        floatIconColor: this.iconColor ?? this.iconColor
      })
        .onClick(() => {
          this.onBackClicked();
        })

      if (!this.isFloating) {
        Row() {
          this.content();
        }
        .layoutWeight(1)
      }

      if (!this.buttons && this.isContentCenter) {
        Row()
          .width(CommonConstant.IconSizeLarge)
      }

      if (this.buttons) {
        Row({ space: CommonConstant.NormalContainerInnerPadding }) {
          ForEach(this.buttons, (navTitleButtonModel: NavTitleButtonModel) => {
            FloatButton({
              isFloating: this.isFloating,
              floatIcon: navTitleButtonModel.icon,
              floatIconColor: navTitleButtonModel.color ?? this.iconColor
            })
              .onClick(() => {
                navTitleButtonModel.onClick();
              })
              .geometryTransition(navTitleButtonModel.geometryID ?? undefined)
          })
        }
      }
    }
    .height(this.vm.window.windowTopPadding + CommonConstant.TopBarHeight)
    .width(CommonConstant.FullPercent)
    .backgroundColor(this.isFloating ? Color.Transparent : this.bgColor)
    .padding({
      top: this.vm.window.windowTopPadding,
      left: CommonConstant.PageLRPadding,
      right: CommonConstant.PageLRPadding
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .animation({
      duration: CommonConstant.AnimationDurationNormal,
      curve: CommonConstant.AnimationCurveSpring
    })
  }
}