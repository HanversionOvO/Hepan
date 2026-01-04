import { AppUtil } from '@pura/harmony-utils';
import { CommonConstant, ToastUtil, VMManager } from 'base_common';
import { CustomMarkdown, FloatButton, GlassButton } from 'base_ui';
import { DraftModel, DraftVM } from '../viewmodels/DraftVM';
import { PostPageVM } from '../viewmodels/PostPageVM';

@Builder
export function postDraftBuilder(pVM: PostPageVM) {
  PostDraft({ pVM: pVM });
}

@ComponentV2
struct PostDraft {
  @Local vm: DraftVM = VMManager.get(DraftVM, () => new DraftVM());
  @Param @Require pVM: PostPageVM;
  @Local isShowContent: boolean = false;
  @Local isHideSave: boolean = false;
  @Local selectedDraft: DraftModel | null = null;

  onBackPress() {
    if (this.isShowContent) {
      AppUtil.getUIContext()
        .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring },
          () => {
            this.isShowContent = false;
            this.selectedDraft = null;
          })
    }
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
        this.toggleHeader(true);
      } else if (yOffset < -CommonConstant.ScrollAnimationThreshold) {
        this.toggleHeader(false);
      }
    }
  }

  @Builder
  DeleteAction(item: DraftModel) {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.trash'))
          .fontColor([$r('sys.color.font_on_primary')])
          .fontSize(CommonConstant.TextSizeLarge)
      }
      .type(ButtonType.Circle)
      .backgroundColor(CommonConstant.ErrorColor)
      .width(CommonConstant.IconSizeLarge)
      .height(CommonConstant.IconSizeLarge)
      .onClick(() => {
        const index = this.vm.draftList.indexOf(item);
        this.vm.deleteDraft(index);
      })
    }
    .padding({ left: CommonConstant.NormalContainerInnerPadding, right: CommonConstant.NormalContainerInnerPadding })
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  DraftItem(item: DraftModel) {
    Row({ space: CommonConstant.NormalContainerInnerPadding }) {
      Divider()
        .strokeWidth(CommonConstant.BorderSizeHuge)
        .vertical(true)
        .height(CommonConstant.TextSizeNormal)
        .color(CommonConstant.ThemeColor)
        .borderRadius(CommonConstant.RadiusRound)

      Column({ space: CommonConstant.SmallContainerInnerPadding }) {
        Row({ space: CommonConstant.NormalContainerInnerPadding }) {
          Text(item.title || $r('app.string.PostPage_draft_no_title'))
            .fontSize(CommonConstant.TextSizeNormal)
            .fontWeight(FontWeight.Bold)
            .maxLines(1)
            .layoutWeight(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(item.timeStr)
            .fontSize(CommonConstant.TextSizeTiny)
            .fontColor($r('sys.color.font_tertiary'))
        }

        Text(item.content || $r('app.string.PostPage_draft_no_content'))
          .fontSize(CommonConstant.TextSizeSmall)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor($r('sys.color.font_secondary'))
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
    .width(CommonConstant.FullPercent)
    .onClick(() => {
      this.selectedDraft = item;
      AppUtil.getUIContext()
        .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring },
          () => {
            this.isShowContent = true;
          })
    })
  }

  @Builder
  ContentPage() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        Text(this.selectedDraft?.title || $r('app.string.PostPage_draft_no_title'))
          .fontSize(CommonConstant.TextSizeLarge)
          .fontWeight(FontWeight.Bold)
          .width(CommonConstant.FullPercent)
          .padding({
            left: CommonConstant.NormalContainerLRPadding,
            right: CommonConstant.NormalContainerLRPadding,
            top: CommonConstant.NormalContainerTBPadding
          })

        Divider()
          .margin({ top: CommonConstant.SmallContainerTBPadding, bottom: CommonConstant.SmallContainerTBPadding })

        Scroll() {
          Column() {
            CustomMarkdown({
              content: this.selectedDraft?.content || ""
            })
              .width(CommonConstant.FullPercent)

            Column()
              .height(this.vm.isTabletView ? CommonConstant.NormalContainerTBPadding + CommonConstant.IconSizeLarge :
                this.vm.window.windowBottomPadding + CommonConstant.IconSizeLarge)
          }
        }
        .layoutWeight(1)
        .width(CommonConstant.FullPercent)
        .align(Alignment.TopStart)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)

      Row({ space: CommonConstant.NormalContainerInnerPadding }) {
        FloatButton({
          isFloating: true
        })
          .onClick(() => {
            AppUtil.getUIContext()
              .animateTo({
                duration: CommonConstant.AnimationDurationNormal,
                curve: CommonConstant.AnimationCurveSpring
              },
                () => {
                  this.isShowContent = false;
                  this.selectedDraft = null;
                })
          })

        GlassButton({
          text: $r('app.string.PostPage_draft_use'),
          symbol: $r('sys.symbol.square_and_pencil'),
        })
          .onClick(() => {
            if (this.selectedDraft) {
              this.pVM.postTitle = this.selectedDraft.title;
              this.pVM.markdownContent = this.selectedDraft.content;
              this.pVM.isShowDraft = false;
            }
          })
      }
      .margin({
        bottom: this.vm.isTabletView ? CommonConstant.NormalContainerTBPadding : this.vm.window.windowBottomPadding
      })
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
    .transition(TransitionEffect.asymmetric(
      TransitionEffect.move(TransitionEdge.END),
      TransitionEffect.move(TransitionEdge.END)
    ))
  }

  @Builder
  ListPage() {
    Stack({ alignContent: Alignment.Bottom }) {
      List({ space: CommonConstant.NormalContainerInnerPadding }) {
        if (this.vm.draftList.length === 0) {
          ListItem() {
            Column() {
              Text($r('app.string.PostPage_draft_no_draft'))
                .fontColor($r('sys.color.font_tertiary'))
                .fontSize(CommonConstant.TextSizeNormal)
            }
            .width(CommonConstant.FullPercent)
            .justifyContent(FlexAlign.Center)
            .padding({
              top: CommonConstant.NormalContainerTBPadding,
              bottom: CommonConstant.NormalContainerTBPadding
            })
          }
        } else {
          ForEach(this.vm.draftList, (item: DraftModel) => {
            ListItem() {
              this.DraftItem(item)
            }
            .swipeAction({
              end: () => {
                this.DeleteAction(item)
              }
            })
          })
        }

        ListItem()
          .height(this.vm.isTabletView ? CommonConstant.NormalContainerTBPadding + CommonConstant.IconSizeLarge :
            this.vm.window.windowBottomPadding + CommonConstant.IconSizeLarge)
      }
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .padding({
        left: CommonConstant.NormalContainerLRPadding,
        right: CommonConstant.NormalContainerLRPadding
      })
      .onDidScroll((scrollOffset: number, scrollState: ScrollState) => {
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
          .onClick(async () => {
            if ((!this.pVM.postTitle || this.pVM.postTitle.trim() === '') &&
              (!this.pVM.markdownContent || this.pVM.markdownContent.trim() === '')) {
              ToastUtil.showError($r('app.string.PostPage_draft_no_title_content'));
              return;
            }

            await this.vm.saveDraft(this.pVM.postTitle, this.pVM.markdownContent);
          })
      }
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
    .transition(TransitionEffect.asymmetric(
      TransitionEffect.move(TransitionEdge.START),
      TransitionEffect.move(TransitionEdge.START)
    ))
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