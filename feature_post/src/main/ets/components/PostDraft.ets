import { AppUtil } from '@pura/harmony-utils';
import { CommonConstant, ToastUtil, VMManager } from 'base_common';
import { CustomMarkdown, GlassButton } from 'base_ui';
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
        this.toggleHeader(false);
      } else if (yOffset < -CommonConstant.ScrollAnimationThreshold) {
        this.toggleHeader(true);
      }
    }
  }

  // [新增] 侧滑删除按钮的 Builder
  @Builder
  DeleteAction(item: DraftModel) {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.trash'))
          .fontColor([Color.White])
          .fontSize(24)
      }
      .type(ButtonType.Circle)
      .backgroundColor(CommonConstant.ErrorColor)
      .width(40)
      .height(40)
      .onClick(() => {
        const index = this.vm.draftList.indexOf(item);
        this.vm.deleteDraft(index);
      })
    }
    .padding({ left: 10, right: 10 })
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
          Text(item.title || "无标题")
            .fontSize(CommonConstant.TextSizeNormal)
            .fontWeight(FontWeight.Bold)
            .maxLines(1)
            .layoutWeight(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(item.timeStr)
            .fontSize(CommonConstant.TextSizeTiny)
            .fontColor($r('sys.color.font_tertiary'))
        }

        Text(item.content || "无内容")
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
    .width('100%')
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
        // 预览标题
        Text(this.selectedDraft?.title || "无标题")
          .fontSize(CommonConstant.TextSizeLarge)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .padding({
            left: CommonConstant.NormalContainerLRPadding,
            right: CommonConstant.NormalContainerLRPadding,
            top: CommonConstant.NormalContainerTBPadding
          })

        Divider()
          .margin({ top: CommonConstant.SmallContainerTBPadding, bottom: CommonConstant.SmallContainerTBPadding })

        // 预览内容
        Scroll() {
          Column() {
            CustomMarkdown({ content: this.selectedDraft?.content || "" })
          }
          .width('100%')
          .padding({
            left: CommonConstant.NormalContainerLRPadding,
            right: CommonConstant.NormalContainerLRPadding,
            bottom: 100 // 留出底部按钮空间
          })
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)

      GlassButton({
        text: "使用此草稿",
        symbol: $r('sys.symbol.square_and_pencil'),
      })
        .margin({
          bottom: this.vm.isTabletView ? CommonConstant.NormalContainerTBPadding : this.vm.window.windowBottomPadding
        })
        .onClick(() => {
          if (this.selectedDraft) {
            this.pVM.postTitle = this.selectedDraft.title;
            this.pVM.markdownContent = this.selectedDraft.content;
            this.pVM.isShowDraft = false;
            ToastUtil.showSuccess("已加载草稿内容");
          }
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
              Text("暂无草稿")
                .fontColor($r('sys.color.font_tertiary'))
                .fontSize(CommonConstant.TextSizeNormal)
                .margin({ top: 100 })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
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
          .height(this.vm.isTabletView ? 100 : this.vm.window.windowBottomPadding + 80)
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
              ToastUtil.showError("标题和内容不能同时为空");
              return;
            }

            const success = await this.vm.saveDraft(this.pVM.postTitle, this.pVM.markdownContent);
            if (success) {
              ToastUtil.showSuccess("草稿保存成功");
            } else {
              ToastUtil.showError("草稿保存失败");
            }
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