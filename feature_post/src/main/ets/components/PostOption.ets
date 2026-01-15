import { AppUtil } from '@pura/harmony-utils';
import { CommonConstant } from 'base_common';
import { PostPageVM } from '../viewmodels/PostPageVM';

@ComponentV2
export struct PostOption {
  @Param @Require vm: PostPageVM;

  @Builder
  actionButton(icon: Resource, label: ResourceStr, onClick: () => void) {
    Row({ space: CommonConstant.SmallContainerInnerPadding }) {
      SymbolGlyph(icon)
        .fontSize(CommonConstant.TextSizeSmall)
        .fontColor([$r('sys.color.font_tertiary')])

      Text(label)
        .fontSize(CommonConstant.TextSizeSmall)
        .fontColor($r('sys.color.font_tertiary'))
    }
    .backgroundColor($r('app.color.second_window_background'))
    .padding({
      left: CommonConstant.SmallContainerLRPadding / 2,
      right: CommonConstant.SmallContainerLRPadding / 2,
      top: CommonConstant.SmallContainerTBPadding / 2,
      bottom: CommonConstant.SmallContainerTBPadding / 2
    })
    .borderRadius(CommonConstant.RadiusRound)
    .onClick(() => {
      onClick();
    })
    .animation({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring })
    .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.85 })
  }

  build() {
    Row({ space: CommonConstant.NormalContainerInnerPadding }) {
      this.actionButton($r('sys.symbol.data'), $r('app.string.PostPage_insert_vote'), () => {
      })

      this.actionButton($r('sys.symbol.drop'), $r('app.string.PostPage_post_water'), () => {
      })

      Toggle({ type: ToggleType.Button, isOn: this.vm.isAnonymous }) {
        Row({ space: CommonConstant.SmallContainerInnerPadding }) {
          SymbolGlyph($r('sys.symbol.security_shield'))
            .fontSize(CommonConstant.TextSizeSmall)
            .fontColor(this.vm.isAnonymous ? [$r('sys.color.font_on_primary')] : [$r('sys.color.font_tertiary')])

          Text($r('app.string.PostPage_enable_anonymous'))
            .fontSize(CommonConstant.TextSizeSmall)
            .fontColor(this.vm.isAnonymous ? $r('sys.color.font_on_primary') : $r('sys.color.font_tertiary'))
        }
      }
      .backgroundColor($r('app.color.second_window_background'))
      .selectedColor(CommonConstant.ThemeColor)
      .onChange((isOn: boolean) => {
        AppUtil.getUIContext().animateTo({ duration: CommonConstant.AnimationDurationNormal }, () => {
          void this.vm.setAnonymous(isOn);
        })
      })
      .padding({
        left: CommonConstant.SmallContainerLRPadding / 2,
        right: CommonConstant.SmallContainerLRPadding / 2,
        top: CommonConstant.SmallContainerTBPadding / 2,
        bottom: CommonConstant.SmallContainerTBPadding / 2
      })
      .animation({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring })
      .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.85 })
    }
    .justifyContent(FlexAlign.Start)
  }
}
