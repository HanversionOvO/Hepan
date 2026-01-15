import { AppUtil } from '@pura/harmony-utils';
import { CommonConstant } from 'base_common';
import { PostPageVM } from '../viewmodels/PostPageVM';

@ComponentV2
export struct PostOption {
  @Param @Require vm: PostPageVM;

  build() {
    Row({ space: CommonConstant.NormalContainerInnerPadding }) {
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
      .selectedColor(CommonConstant.ThemeColor)
      .onChange((isOn: boolean) => {
        AppUtil.getUIContext().animateTo({ duration: CommonConstant.AnimationDurationNormal }, () => {
          this.vm.isAnonymous = isOn;
        })
      })
      .padding({
        left: CommonConstant.SmallContainerLRPadding / 2,
        right: CommonConstant.SmallContainerLRPadding / 2,
        top: CommonConstant.SmallContainerTBPadding / 2,
        bottom: CommonConstant.SmallContainerTBPadding / 2
      })
    }
    .justifyContent(FlexAlign.Start)
  }
}