import { CommonConstant, ForumApi } from 'base_common';
import { TieContentPageVM } from '../viewmodels/TieContentPageVM';

@Builder
export function tieCollectSheet(vm: TieContentPageVM) {
  TieCollectSheet({ vm: vm })
}

@ComponentV2
struct TieCollectSheet {
  @Param @Require vm: TieContentPageVM;

  // TODO: 这里需要初始化收藏列表 @Local xxx

  async aboutToAppear() {
    await ForumApi.collectTie(this.vm.tieThread.thread_id);
  }

  @Builder
  CollectionItem(isFavorite: boolean, isPersonal: boolean) {
    Row() {
      Row({ space: CommonConstant.SmallContainerInnerPadding }) {
        SymbolGlyph(isPersonal ? $r('sys.symbol.person') : $r('sys.symbol.bookshelf'))
          .fontSize(CommonConstant.TextSizeLarge)
          .padding(CommonConstant.NormalContainerInnerPadding)
          .borderRadius(CommonConstant.RadiusNormal)
          .border({
            width: CommonConstant.BorderSizeNormal,
            color: $r('sys.color.font_tertiary'),
            style: BorderStyle.Dashed
          })

        Text(isPersonal ? $r('app.string.TieContentPage_personal_collection') : "//TODO: 这里放name")
          .fontSize(CommonConstant.TextSizeNormal)
      }

      Row({ space: CommonConstant.SmallContainerInnerPadding }) {
        Text(isFavorite ? $r('app.string.TieContentPage_remove_collection') :
          $r('app.string.TieContentPage_add_collection'))
          .fontSize(CommonConstant.TextSizeSmall)
          .fontColor($r('sys.color.font_secondary'))

        SymbolGlyph(isFavorite ? $r('sys.symbol.minus') : $r('sys.symbol.plus'))
          .fontSize(CommonConstant.TextSizeSmall)
          .fontColor([$r('sys.color.font_secondary')])
      }
    }
    .padding({
      left: CommonConstant.NormalContainerLRPadding,
      right: CommonConstant.NormalContainerLRPadding,
      top: CommonConstant.NormalContainerTBPadding,
      bottom: CommonConstant.NormalContainerTBPadding
    })
    .width(CommonConstant.FullPercent)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  build() {
    Column() {
      // TODO: 这里实现收藏列表
    }
    .width(CommonConstant.FullPercent)
    .borderRadius(CommonConstant.RadiusNormal)
    .padding({
      left: CommonConstant.NormalContainerLRPadding,
      right: CommonConstant.NormalContainerLRPadding,
      bottom: this.vm.window.windowBottomPadding + CommonConstant.NormalContainerTBPadding
    })
    .backgroundColor($r('app.color.start_window_background'))
  }
}