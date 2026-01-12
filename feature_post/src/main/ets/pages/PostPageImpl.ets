import { AppUtil } from '@pura/harmony-utils'
import { AtUser, CommonConstant, TransitionMap } from 'base_common'
import { CustomAtPanel, CustomFacePanel, CustomMarkdown, CustomNavTitle, FloatButton } from 'base_ui'
import { CategoryPicker } from '../components/CategoryPicker'
import { ImagePicker } from '../components/ImagePicker'
import { RichTextToolBar } from '../components/RichTextToolBar'
import { PostPageVM } from '../viewmodels/PostPageVM'
import { KeyboardAvoidMode } from '@kit.ArkUI'
import { postDraftBuilder } from '../components/PostDraft'

const TAG = '[PostPageImpl]: ';

@ComponentV2
export struct PostPageImpl {
  @Local vm: PostPageVM = new PostPageVM()

  @Monitor("vm.isTabletView")
  changeKeyBoardMode() {
    this.setKeyboardMode();
  }

  private setKeyboardMode() {
    if (!this.vm.isTabletView) {
      this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE_WITH_CARET)
    } else {
      this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET)
    }
  }

  private resetKeyboardMode() {
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET)
  }

  aboutToDisappear(): void {
    this.resetKeyboardMode()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        CustomNavTitle({
          vm: this.vm,
          title: $r('app.string.PostPage_title'),
          buttons: this.vm.titleButtons
        })
          .bindSheet($$this.vm.isShowDraft, postDraftBuilder(this.vm), {
            showClose: true,
            detents: [SheetSize.LARGE],
            enableOutsideInteractive: false,
            preferType: SheetType.CENTER,
            backgroundColor: $r('app.color.glass_background'),
            blurStyle: BlurStyle.BACKGROUND_ULTRA_THICK,
            title: {
              title: $r('app.string.PostPage_draft_title')
            }
          })

        Flex({
          direction: this.vm.isTabletView ? FlexDirection.Row : FlexDirection.ColumnReverse
        }) {
          if (this.vm.isTabletView || !this.vm.isPreviewMode) {
            RichTextToolBar({ vm: this.vm, buttons: this.vm.richTextButtons })

            Column({ space: CommonConstant.LargeContainerInnerPadding }) {
              ImagePicker({ vm: this.vm })

              if (this.vm.isTabletView || !this.vm.isInputting) {
                CategoryPicker({ vm: this.vm })
                  .transition(TransitionEffect.OPACITY
                    .combine(TransitionEffect.translate({ y: -10 }))
                    .combine(TransitionEffect.scale({ y: 0.98 }))
                    .animation({
                      curve: CommonConstant.AnimationCurveSpring,
                      duration: CommonConstant.AnimationDurationNormal
                    })
                  )
              }

              Column() {
                TextInput({ placeholder: $r('app.string.PostPage_post_title'), text: this.vm.postTitle, })
                  .fontSize(CommonConstant.TextSizeLarge)
                  .fontWeight(FontWeight.Bold)
                  .placeholderFont({ weight: FontWeight.Bold, size: CommonConstant.TextSizeLarge })
                  .caretColor(CommonConstant.ThemeColor)
                  .backgroundColor(Color.Transparent)
                  .width(CommonConstant.FullPercent)
                  .padding({
                    left: 0,
                    right: 0
                  })
                  .onFocus(() => {
                    AppUtil.getUIContext()
                      .animateTo({
                        duration: CommonConstant.AnimationDurationNormal,
                        curve: CommonConstant.AnimationCurveSpring
                      }, () => {
                        this.vm.isInputting = true;
                        this.vm.isShowFace = false;
                        this.vm.isShowAt = false;
                        this.vm.setKeyboardInputting(true);
                        if (!this.vm.isTabletView) {
                          this.vm.isCategoryExpanded = false;
                        }
                      })
                  })
                  .onBlur(() => {
                    if (!this.vm.isShowFace) {
                      AppUtil.getUIContext()
                        .animateTo({
                          duration: CommonConstant.AnimationDurationNormal,
                          curve: CommonConstant.AnimationCurveSpring
                        }, () => {
                          this.vm.isInputting = false;
                        })
                    }
                    this.vm.setKeyboardInputting(false);
                  })
                  .onChange((text: string) => {
                    this.vm.postTitle = text;
                  })

                Divider()
                  .width(CommonConstant.FullPercent)
                  .height(CommonConstant.BorderSizeHuge)
                  .color($r('sys.color.font_tertiary'))
              }

              TextArea({
                placeholder: $r('app.string.PostPage_content_placeholder'),
                text: this.vm.markdownContent
              })
                .placeholderFont({
                  size: CommonConstant.TextSizeNormal
                })
                .caretColor(CommonConstant.ThemeColor)
                .padding({ bottom: this.vm.window.windowBottomPadding })
                .width(CommonConstant.FullPercent)
                .fontSize(CommonConstant.TextSizeNormal)
                .borderRadius(0)
                .backgroundColor(Color.Transparent)
                .padding(0)
                .layoutWeight(1)
                .onTextSelectionChange((start: number, end: number) => {
                  this.vm.updateContentSelection(start, end);
                })
                .onFocus(() => {
                  AppUtil.getUIContext()
                    .animateTo({
                      duration: CommonConstant.AnimationDurationNormal,
                      curve: CommonConstant.AnimationCurveSpring
                    }, () => {
                      this.vm.isInputting = true;
                      this.vm.isShowFace = false;
                      this.vm.isShowAt = false;
                      this.vm.setKeyboardInputting(true);
                      this.vm.updateContentSelection(this.vm.markdownContent.length,
                        this.vm.markdownContent.length);
                      if (!this.vm.isTabletView) {
                        this.vm.isCategoryExpanded = false;
                      }
                    })
                })
                .onBlur(() => {
                  AppUtil.getUIContext()
                    .animateTo({
                      duration: CommonConstant.AnimationDurationNormal,
                      curve: CommonConstant.AnimationCurveSpring
                    }, () => {
                      this.vm.isInputting = false;
                    })
                  this.vm.setKeyboardInputting(false);
                })
                .onChange((text: string) => {
                  this.vm.markdownContent = text;
                  this.vm.updateContentSelection(text.length, text.length);
                })
                .margin({
                  bottom: this.vm.window.windowBottomPadding
                })

              if (this.vm.isShowFace) {
                CustomFacePanel({
                  vm: this.vm,
                  onFaceClick: (faceText: string) => {
                    this.vm.insertFace(faceText);
                  }
                })
                  .transition(TransitionEffect.move(TransitionEdge.BOTTOM)
                    .animation({
                      duration: CommonConstant.AnimationDurationNormal,
                      curve: CommonConstant.AnimationCurveSpring
                    }))
              }

              if (this.vm.isShowAt) {
                CustomAtPanel({
                  vm: this.vm,
                  onAtUserClick: (atUser: AtUser) => {
                    this.vm.insertAtUser(atUser);
                  }
                })
                  .transition(TransitionEffect.move(TransitionEdge.BOTTOM)
                    .animation({
                      duration: CommonConstant.AnimationDurationNormal,
                      curve: CommonConstant.AnimationCurveSpring
                    }))
              }
            }
            .padding({ left: CommonConstant.PageLRPadding, right: CommonConstant.PageLRPadding })
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }

          if (this.vm.isTabletView || this.vm.isPreviewMode) {
            Column() {
              if (!this.vm.isTabletView && this.vm.isPreviewMode) {
                Text(this.vm.postTitle || '')
                  .fontSize(CommonConstant.TextSizeLarge)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('sys.color.font_primary'))
                  .width(CommonConstant.FullPercent)
                  .padding({
                    left: CommonConstant.NormalContainerInnerPadding,
                    right: CommonConstant.NormalContainerInnerPadding,
                    top: CommonConstant.LargeContainerInnerPadding,
                    bottom: CommonConstant.SmallContainerInnerPadding
                  })
              }

              Scroll() {
                Column() {
                  CustomMarkdown({
                    content: this.vm.markdownContent,
                    useMarkDown: true
                  })
                    .width(CommonConstant.FullPercent)

                  if (!this.vm.isTabletView) {
                    Column()
                      .height(CommonConstant.BottomBarHeight)
                  }
                }
              }
              .layoutWeight(1)
              .width(CommonConstant.FullPercent)
              .align(Alignment.TopStart)
              .scrollBar(BarState.Off)
              .edgeEffect(EdgeEffect.Spring)
            }
            .width(this.vm.isTabletView ? 340 : CommonConstant.FullPercent)
            .borderRadius(this.vm.isTabletView ? CommonConstant.RadiusLarge : 0)
            .backgroundColor($r('app.color.second_window_background'))
            .margin(this.vm.isTabletView ?
              { right: CommonConstant.PageLRPadding, bottom: this.vm.window.windowBottomPadding } :
              0
            )
            .padding(this.vm.isTabletView ? 0 : {
              left: CommonConstant.PageLRPadding,
              right: CommonConstant.PageLRPadding,
              bottom: this.vm.window.windowBottomPadding
            })
            .geometryTransition(TransitionMap.PostPageMarkDown)
            .layoutWeight(this.vm.isTabletView ? 0 : 1)
          }
        }
        .width(CommonConstant.FullPercent)
        .layoutWeight(1)
      }
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)

      if (!this.vm.isTabletView) {
        FloatButton({
          floatIcon: this.vm.isPreviewMode ? $r('sys.symbol.eye_slash') : $r('sys.symbol.eye'),
          isFloating: true
        })
          .position({
            top: this.vm.window.windowTopPadding + (CommonConstant.TopBarHeight - CommonConstant.IconSizeLarge) / 2,
            right: CommonConstant.PageLRPadding + CommonConstant.NormalContainerInnerPadding * 2 +
              CommonConstant.IconSizeLarge * 2
          })
          .zIndex(2)
          .geometryTransition(TransitionMap.PostPageMarkDown)
          .onClick(() => {
            AppUtil.getUIContext()
              .animateTo({
                duration: CommonConstant.AnimationDurationNormal,
                curve: CommonConstant.AnimationCurveSpring
              }, () => {
                this.vm.isPreviewMode = !this.vm.isPreviewMode;
                if (this.vm.isPreviewMode) {
                  this.vm.isInputting = false;
                }
              })
          })
      }
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
    .transition(CommonConstant.CONF_TRANSITION)
    .backgroundColor($r('app.color.start_window_background'))
    .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number) => {
      if (isVisible) {
        this.setKeyboardMode();
      } else if (!isVisible || currentRatio <= 0.0) {
        this.resetKeyboardMode();
      }
    })
    .onAppear(async () => {
      await this.vm.startPostPage();
    })
  }
}
