import { ResUtil } from '@pura/harmony-utils';
import { CommonConstant } from 'base_common';
import { PostPageVM } from '../viewmodels/PostPageVM';

@Builder
export function voteSheetBuilder(vm: PostPageVM) {
  VoteSheet({ vm })
}

@ComponentV2
struct VoteSheet {
  @Param @Require vm: PostPageVM;
  @Local isShowDelete: boolean = true;

  @Builder
  Segment(label: ResourceStr) {
    Text(label)
      .fontSize(CommonConstant.TextSizeNormal)
      .fontWeight(FontWeight.Medium)
      .width(CommonConstant.FullPercent)
      .textAlign(TextAlign.Start)
  }

  @Builder
  VoteItem(index: number, deleteVoteItem: () => void) {
    Row({ space: CommonConstant.SmallContainerInnerPadding }) {
      TextInput({ placeholder: `${ResUtil.getStringSync($r('app.string.PostPage_vote_item'))} ${index + 1}` })
        .fontSize(CommonConstant.TextSizeNormal)
        .backgroundColor(Color.Transparent)
        .placeholderFont({ size: CommonConstant.TextSizeNormal })
        .caretColor(CommonConstant.ThemeColor)
        .width(0)
        .borderRadius(0)
        .layoutWeight(1)
        .padding(0)

      SymbolGlyph($r('sys.symbol.trash'))
        .fontSize(CommonConstant.TextSizeNormal)
        .fontColor([$r('sys.color.font_secondary')])
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

        this.VoteItem(0, () => {
        })

        this.VoteItem(1, () => {
        })

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
      }
      .width(CommonConstant.FullPercent)
    }
    .width(CommonConstant.FullPercent)
    .padding({
      left: CommonConstant.NormalContainerLRPadding,
      right: CommonConstant.NormalContainerLRPadding,
      bottom: this.vm.window.windowBottomPadding + CommonConstant.NormalContainerTBPadding
    })
  }
}