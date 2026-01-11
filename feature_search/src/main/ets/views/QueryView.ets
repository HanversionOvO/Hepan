import { AppUtil } from '@pura/harmony-utils';
import { CommonConstant, ToastUtil } from 'base_common';
import { StateLayout } from 'base_ui';
import { SearchPageVM } from '../viewmodels/SearchPageVM';
import { LengthMetrics } from '@kit.ArkUI';

@ComponentV2
export struct QueryView {
  @Param vm: SearchPageVM = new SearchPageVM();

  build() {
    StateLayout({
      uiState: this.vm.historyUiState,
      content: () => {
        this.HistoryContent()
      }
    })
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
      .onClick(() => {
        if (this.vm.isHistoryDeleteMode) {
          AppUtil.getUIContext().animateTo({ duration: CommonConstant.AnimationDurationNormal }, () => {
            this.vm.exitDeleteMode();
          });
        }
      })
  }

  @Builder
  HistoryContent() {
    Scroll() {
      Column({ space: CommonConstant.NormalContainerInnerPadding }) {
        Row() {
          Text($r('app.string.SearchPage_query_history'))
            .fontSize(CommonConstant.TextSizeNormal)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_secondary'))
            .layoutWeight(1)

          SymbolGlyph($r('sys.symbol.trash'))
            .fontSize(CommonConstant.TextSizeNormal)
            .fontColor([$r('sys.color.font_tertiary')])
            .onClick(() => {
              ToastUtil.showWarn($r('app.string.SearchPage_query_clear_history'), true,
                $r('app.string.SearchPage_query_tips'), () => {
                  AppUtil.getUIContext().animateTo({ duration: CommonConstant.AnimationDurationNormal }, () => {
                    this.vm.clearHistory();
                  });
                });
            })
        }
        .width(CommonConstant.FullPercent)

        Flex({
          wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, space: {
            main: LengthMetrics.vp(CommonConstant.NormalContainerInnerPadding),
            cross: LengthMetrics.vp(CommonConstant.NormalContainerInnerPadding)
          }
        }) {
          ForEach(this.vm.searchHistory, (keyword: string) => {
            this.HistoryItem(keyword)
          }, (item: string) => item)
        }
        .width(CommonConstant.FullPercent)
        .animation({ duration: CommonConstant.AnimationDurationNormal, curve: Curve.EaseInOut })
      }
      .width(CommonConstant.FullPercent)
      .padding({
        left: CommonConstant.PageLRPadding,
        right: CommonConstant.PageLRPadding,
      })
      .alignItems(HorizontalAlign.Start)
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
    .align(Alignment.TopStart)
  }

  @Builder
  HistoryItem(keyword: string) {
    Row({ space: CommonConstant.SmallContainerInnerPadding }) {
      Text(keyword)
        .fontSize(CommonConstant.TextSizeSmall)
        .fontColor(this.vm.isHistoryDeleteMode ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .animation({ duration: CommonConstant.AnimationDurationNormal })

      if (this.vm.isHistoryDeleteMode) {
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontSize(CommonConstant.TextSizeSmall)
          .fontColor([$r('sys.color.font_on_primary')])
          .transition(TransitionEffect.OPACITY.combine(TransitionEffect.scale({ x: 0.5, y: 0.5 }))
            .animation({ duration: CommonConstant.AnimationDurationNormal }))
          .onClick((event) => {
            AppUtil.getUIContext()
              .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: Curve.EaseInOut }, () => {
                this.vm.deleteHistoryItem(keyword);
              });
          })
      }
    }
    .backgroundColor(this.vm.isHistoryDeleteMode ? CommonConstant.ErrorColor : $r('app.color.second_window_background'))
    .borderRadius(CommonConstant.RadiusNormal)
    .padding({
      left: CommonConstant.SmallContainerLRPadding,
      right: CommonConstant.SmallContainerLRPadding,
      top: CommonConstant.SmallContainerTBPadding,
      bottom: CommonConstant.SmallContainerTBPadding
    })
    .animation({ duration: CommonConstant.AnimationDurationNormal })
    .onClick(() => {
      if (!this.vm.isHistoryDeleteMode) {
        this.vm.onSearchSubmit(keyword)
      }
    })
    .gesture(
      LongPressGesture()
        .onAction(() => {
          AppUtil.getUIContext().animateTo({ duration: CommonConstant.AnimationDurationNormal }, () => {
            this.vm.isHistoryDeleteMode = true;
          })
        })
    )
    .transition(TransitionEffect.OPACITY.combine(TransitionEffect.scale({ x: 0.5, y: 0.5 })))
  }
}