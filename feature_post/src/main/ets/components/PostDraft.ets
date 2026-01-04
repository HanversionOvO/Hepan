import { AppUtil } from '@pura/harmony-utils';
import { CommonConstant, VMManager } from 'base_common';
import { CustomMarkdown, GlassButton } from 'base_ui';
import { DraftVM } from '../viewmodels/DraftVM';
import { PostPageVM } from '../viewmodels/PostPageVM';

@Builder
export function postDraftBuilder(pVM: PostPageVM) {
  PostDraft({ pVM });
}

@ComponentV2
struct PostDraft {
  @Local vm: DraftVM = VMManager.get(DraftVM, () => new DraftVM())
  @Param @Require pVM: PostPageVM;
  @Local isShowContent: boolean = false;
  @Local isHideSave: boolean = false;

  onBackPress() {
    AppUtil.getUIContext()
      .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring },
        () => {
          this.isShowContent = false;
        })
  }

  toggleHeader(hide: boolean) {
    AppUtil.getUIContext()
      .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring },
        () => {
          this.isHideSave = hide;
        })
  }

  private handleScroll(yOffset: number, scrollState: ScrollState) {
    if (scrollState === ScrollState.Scroll) {
      if (yOffset > CommonConstant.ScrollAnimationThreshold) {
        this.toggleHeader(false);
      } else if (yOffset < -CommonConstant.ScrollAnimationThreshold) {
        this.toggleHeader(true);
      }
    }
  }

  @Builder
  DraftItem(title: string, content: string, time: string) {
    Row({ space: CommonConstant.NormalContainerInnerPadding }) {
      Divider()
        .strokeWidth(CommonConstant.BorderSizeHuge)
        .vertical(true)
        .height(CommonConstant.TextSizeNormal)
        .color(CommonConstant.ThemeColor)
        .borderRadius(CommonConstant.RadiusRound)

      Column({ space: CommonConstant.SmallContainerInnerPadding }) {
        Row({ space: CommonConstant.NormalContainerInnerPadding }) {
          Text(title)
            .fontSize(CommonConstant.TextSizeNormal)
            .fontWeight(FontWeight.Bold)
            .maxLines(1)
            .layoutWeight(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(time)
            .fontSize(CommonConstant.TextSizeTiny)
            .fontColor($r('sys.color.font_tertiary'))
        }

        Text(content)
          .fontSize(CommonConstant.TextSizeSmall)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .borderRadius(CommonConstant.RadiusLarge)
    .padding({
      left: CommonConstant.NormalContainerLRPadding,
      right: CommonConstant.NormalContainerLRPadding,
      top: CommonConstant.NormalContainerTBPadding,
      bottom: CommonConstant.NormalContainerTBPadding
    })
    .backgroundColor($r('app.color.start_window_background'))
    .alignItems(VerticalAlign.Top)
    .onClick(() => {
      AppUtil.getUIContext()
        .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring },
          () => {
            this.isShowContent = true;
          })
    })
  }

  @Builder
  ContentPage() {
    // TODO: 内容的显示
    Column() {
      CustomMarkdown({ content: "test" })
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
  }

  @Builder
  ListPage() {
    List({ space: CommonConstant.NormalContainerInnerPadding }) {
      // TODO: 此处放列表

      ListItem()
        .height(this.vm.isTabletView ? 0 : this.vm.window.windowBottomPadding)
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .padding({
      left: CommonConstant.NormalContainerLRPadding,
      right: CommonConstant.NormalContainerLRPadding
    })
    .onDidScroll((scrollOffset, scrollState) => {
      this.handleScroll(scrollOffset, scrollState);
    })

    if (!this.isHideSave) {
      GlassButton({
        text: $r('app.string.PostPage_draft_save'),
        symbol: $r('sys.symbol.save_fill')
      })
        .margin({
          bottom: this.vm.isTabletView ? CommonConstant.NormalContainerTBPadding : this.vm.window.windowBottomPadding
        })
        .transition(TransitionEffect.move(TransitionEdge.BOTTOM)
          .animation({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring })
        )
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      if (this.isShowContent) {
        this.ContentPage()
      } else {
        this.ListPage()
      }
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
  }
}