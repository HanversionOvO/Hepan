import { AppUtil } from '@pura/harmony-utils';
import { CommonConstant } from 'base_common';
import { PostPageVM } from '../viewmodels/PostPageVM';
import { voteSheetBuilder } from './VoteSheet';

@ComponentV2
struct ActionButton {
  @Param @Require icon: Resource;
  @Param @Require label: ResourceStr;

  build() {
    Row({ space: CommonConstant.SmallContainerInnerPadding }) {
      SymbolGlyph(this.icon)
        .fontSize(CommonConstant.TextSizeSmall)
        .fontColor([$r('sys.color.font_tertiary')])

      Text(this.label)
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
    .animation({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring })
    .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.85 })
  }
}

@ComponentV2
export struct PostOption {
  @Param @Require vm: PostPageVM;

  build() {
    Row({ space: CommonConstant.NormalContainerInnerPadding }) {
      ActionButton({
        icon: $r('sys.symbol.data'),
        label: $r('app.string.PostPage_insert_vote'),
      })
        .onClick(() => {
          this.vm.isShowVote = true;
        })
        .bindSheet($$this.vm.isShowVote, voteSheetBuilder(this.vm), {
          showClose: true,
          detents: [SheetSize.FIT_CONTENT],
          enableOutsideInteractive: false,
          preferType: this.vm.isTabletView ? SheetType.CENTER : SheetType.BOTTOM,
          backgroundColor: $r('app.color.start_window_background'),
          blurStyle: BlurStyle.BACKGROUND_ULTRA_THICK,
          title: {
            title: $r('app.string.PostPage_insert_vote')
          }
        })

      ActionButton({
        icon: $r('sys.symbol.drop'),
        label: $r('app.string.PostPage_post_water'),
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
