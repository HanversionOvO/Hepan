import { ResUtil } from '@pura/harmony-utils';
import { CommonConstant, PoolOption } from 'base_common';
import { PostPageVM } from '../viewmodels/PostPageVM';

@Builder
export function voteSheetBuilder(vm: PostPageVM) {
  VoteSheet({ vm })
}

@ComponentV2
struct VoteOption {
  @Param @Require icon: Resource;
  @Param @Require label: ResourceStr;
  @Param @Require isCheck: boolean;
  @Param @Require onChange: (isOn: boolean) => void;

  build() {
    Row() {
      Row({ space: CommonConstant.NormalContainerInnerPadding }) {
        SymbolGlyph(this.icon)
          .fontSize(CommonConstant.TextSizeNormal)
          .fontColor([CommonConstant.ThemeColor])

        Text(this.label)
          .fontSize(CommonConstant.TextSizeNormal)
      }

      Toggle({ type: ToggleType.Switch, isOn: this.isCheck })
        .selectedColor(CommonConstant.ThemeColor)
        .onChange((isOn: boolean) => {
          this.onChange(isOn);
        })
    }
    .width(CommonConstant.FullPercent)
    .width(CommonConstant.FullPercent)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}

@ComponentV2
struct VoteSheet {
  @Param @Require vm: PostPageVM;

  @Builder
  Segment(label: ResourceStr) {
    Text(label)
      .fontSize(CommonConstant.TextSizeNormal)
      .fontWeight(FontWeight.Medium)
      .width(CommonConstant.FullPercent)
      .textAlign(TextAlign.Start)
  }

  @Builder
  VoteItem(option: PoolOption, index: number, deleteVoteItem: () => void) {
    Row({ space: CommonConstant.SmallContainerInnerPadding }) {
      TextInput({
        placeholder: `${ResUtil.getStringSync($r('app.string.PostPage_vote_item'))} ${index + 1}`,
        text: option.text
      })
        .fontSize(CommonConstant.TextSizeNormal)
        .backgroundColor(Color.Transparent)
        .placeholderFont({ size: CommonConstant.TextSizeNormal })
        .caretColor(CommonConstant.ThemeColor)
        .width(0)
        .borderRadius(0)
        .layoutWeight(1)
        .padding(0)
        .onChange((text: string) => {
          option.text = text;
        })

      SymbolGlyph($r('sys.symbol.trash'))
        .fontSize(CommonConstant.TextSizeNormal)
        .fontColor([$r('sys.color.font_secondary')])
        .onClick(() => {
          deleteVoteItem();
        })
    }
    .backgroundColor($r('app.color.second_window_background'))
    .borderRadius(CommonConstant.RadiusSmall)
    .padding({
      left: CommonConstant.SmallContainerLRPadding,
      right: CommonConstant.SmallContainerLRPadding,
      top: CommonConstant.SmallContainerTBPadding,
      bottom: CommonConstant.SmallContainerTBPadding
    })
    .width(CommonConstant.FullPercent)
  }

  build() {
    Column({ space: CommonConstant.LargeContainerInnerPadding }) {
      Column({ space: CommonConstant.SmallContainerTBPadding }) {
        this.Segment($r('app.string.PostPage_vote_item_title'))

        ForEach(this.vm.vote.options, (option: PoolOption, index: number) => {
          this.VoteItem(option, index, () => {
            this.vm.removeVoteOption(index);
          })
        }, (_option: PoolOption, index: number) => index.toString())

        Row({ space: CommonConstant.NormalContainerInnerPadding }) {
          SymbolGlyph($r('sys.symbol.plus'))
            .fontSize(CommonConstant.TextSizeNormal)
            .fontColor([CommonConstant.ThemeColor])

          Text($r('app.string.PostPage_vote_item_insert'))
            .fontSize(CommonConstant.TextSizeNormal)
            .fontColor(CommonConstant.ThemeColor)
        }
        .justifyContent(FlexAlign.Center)
        .width(CommonConstant.FullPercent)
        .padding(CommonConstant.NormalContainerInnerPadding)
        .borderRadius(CommonConstant.RadiusSmall)
        .border({ width: CommonConstant.BorderSizeLarge, color: CommonConstant.ThemeColor, style: BorderStyle.Dashed })
        .animation({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring })
        .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.85 })
        .onClick(() => {
          this.vm.addVoteOption();
        })
      }
      .width(CommonConstant.FullPercent)

      Column({ space: CommonConstant.SmallContainerTBPadding }) {
        this.Segment($r('app.string.PostPage_vote_option_title'))

        Column({ space: CommonConstant.NormalContainerInnerPadding }) {
          VoteOption({
            icon: $r('sys.symbol.checkmark_cart'),
            label: $r('app.string.PostPage_vote_show_result'),
            isCheck: this.vm.vote.visible,
            onChange: (isOn: boolean) => {
              this.vm.setVoteVisible(isOn);
            }
          })

          VoteOption({
            icon: $r('sys.symbol.visibility'),
            label: $r('app.string.PostPage_vote_show_voter'),
            isCheck: this.vm.vote.show_voters,
            onChange: (isOn: boolean) => {
              this.vm.setVoteShowVoters(isOn);
            }
          })

          Row() {
            Row({ space: CommonConstant.NormalContainerInnerPadding }) {
              SymbolGlyph($r('sys.symbol.checkmark'))
                .fontSize(CommonConstant.TextSizeNormal)
                .fontColor([CommonConstant.ThemeColor])

              Text($r('app.string.PostPage_vote_max_choices'))
                .fontSize(CommonConstant.TextSizeNormal)
            }

            Row({ space: CommonConstant.NormalContainerInnerPadding }) {
              SymbolGlyph($r('sys.symbol.minus'))
                .fontSize(CommonConstant.TextSizeSmall)
                .fontColor([this.vm.canDecVoteChoice() ? CommonConstant.ThemeColor : $r('sys.color.font_tertiary')])
                .onClick(() => {
                  if (this.vm.canDecVoteChoice()) {
                    this.vm.updateVoteMaxChoices(this.vm.vote.max_choices - 1);
                  }
                })
                .backgroundColor($r('app.color.start_window_background'))
                .borderRadius(CommonConstant.RadiusRound)
                .padding(CommonConstant.SmallContainerInnerPadding)

              Text(`${this.vm.vote.max_choices}`)
                .fontSize(CommonConstant.TextSizeNormal)

              SymbolGlyph($r('sys.symbol.plus'))
                .fontSize(CommonConstant.TextSizeSmall)
                .fontColor([this.vm.canIncVoteChoice() ? CommonConstant.ThemeColor : $r('sys.color.font_tertiary')])
                .onClick(() => {
                  if (this.vm.canIncVoteChoice()) {
                    this.vm.updateVoteMaxChoices(this.vm.vote.max_choices + 1);
                  }
                })
                .backgroundColor($r('app.color.start_window_background'))
                .borderRadius(CommonConstant.RadiusRound)
                .padding(CommonConstant.SmallContainerInnerPadding)
            }
            .borderRadius(CommonConstant.RadiusRound)
            .border({ width: CommonConstant.BorderSizeNormal, color: $r('app.color.start_window_background') })
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width(CommonConstant.FullPercent)

          Row() {
            Row({ space: CommonConstant.NormalContainerInnerPadding }) {
              SymbolGlyph($r('sys.symbol.calendar'))
                .fontSize(CommonConstant.TextSizeNormal)
                .fontColor([CommonConstant.ThemeColor])

              Text($r('app.string.PostPage_vote_time'))
                .fontSize(CommonConstant.TextSizeNormal)
            }

            CalendarPicker()
              .textStyle({ font: { size: CommonConstant.TextSizeSmall } })
              .onChange((date: Date) => {
                this.vm.updateVoteExpiration(date);
              })
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width(CommonConstant.FullPercent)
        }
        .padding({
          top: CommonConstant.NormalContainerTBPadding,
          bottom: CommonConstant.NormalContainerTBPadding,
          left: CommonConstant.NormalContainerLRPadding,
          right: CommonConstant.NormalContainerLRPadding
        })
        .width(CommonConstant.FullPercent)
        .backgroundColor($r('app.color.second_window_background'))
        .borderRadius(CommonConstant.RadiusNormal)
      }
      .width(CommonConstant.FullPercent)

      Button($r('app.string.PostPage_vote_delete'))
        .fontSize(CommonConstant.TextSizeNormal)
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor(CommonConstant.ThemeColor)
        .borderRadius(CommonConstant.RadiusSmall)
        .width(CommonConstant.FullPercent)
        .onClick(() => {
          this.vm.clearVote();
        })
    }
    .width(CommonConstant.FullPercent)
    .padding({
      left: CommonConstant.NormalContainerLRPadding,
      right: CommonConstant.NormalContainerLRPadding,
      bottom: this.vm.window.windowBottomPadding + CommonConstant.NormalContainerTBPadding
    })
    .onAppear(() => {
      this.vm.normalizeVoteMaxChoices();
    })
  }
}
