import { AppUtil } from '@pura/harmony-utils'
import { AtUser, CommonConstant, TransitionMap, VMManager } from 'base_common'
import { CustomAtPanel, CustomFacePanel, CustomMarkdown, CustomNavTitle, FloatButton } from 'base_ui'
import { CategoryPicker } from '../components/CategoryPicker'
import { ImagePicker } from '../components/ImagePicker'
import { RichTextToolBar } from '../components/RichTextToolBar'
import { PostPageVM } from '../viewmodels/PostPageVM'
import { KeyboardAvoidMode } from '@kit.ArkUI'

const TAG = '[PostPageImpl]: ';

@ComponentV2
export struct PostPageImpl {
  @Local vm: PostPageVM = VMManager.get(PostPageVM, () => new PostPageVM())

  @Monitor("vm.isTabletView")
  changeKeyBoardMode() {
    if (!this.vm.isTabletView) {
      this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE_WITH_CARET)
    } else {
      this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET)
    }
  }

  aboutToAppear(): void {
    if (!this.vm.isTabletView) {
      this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE_WITH_CARET)
    } else {
      this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET)
    }
  }

  aboutToDisappear(): void {
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET)
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Column() {
          CustomNavTitle({
            vm: this.vm,
            title: $r('app.string.PostPage_title'),
            buttons: this.vm.titleButtons
          })

          Flex({
            direction: this.vm.isTabletView ? FlexDirection.Row : FlexDirection.ColumnReverse
          }) {
            if (this.vm.isTabletView || !this.vm.isPreviewMode) {
              RichTextToolBar({ vm: this.vm, buttons: this.vm.richTextButtons })

              Column({ space: CommonConstant.LargeContainerInnerPadding }) {
                ImagePicker({ vm: this.vm })

                CategoryPicker({ vm: this.vm })

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
                    }) // 确保标题变化同步回VM

                  Divider()
                    .width(CommonConstant.FullPercent)
                    .height(CommonConstant.BorderSizeHuge)
                    .color($r('sys.color.font_tertiary'))
                }

                TextArea({ placeholder: $r('app.string.PostPage_content_placeholder'), text: this.vm.markdownContent })
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
                  })

                if (this.vm.isShowFace) {
                  CustomFacePanel({
                    vm: this.vm,
                    onFaceClick: (face: ResourceStr) => {
                      if (typeof face === 'string') {
                        this.vm.markdownContent += face;
                      }
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
                      // 插入 @用户名
                      this.vm.markdownContent += `@${atUser.username} `;
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
                  CustomMarkdown({
                    content: this.vm.markdownContent,
                    controller: this.vm.markdownController
                  })
                    .width(CommonConstant.FullPercent)
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
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.start_window_background'))
    .onReady(async () => {
      await this.vm.startPostPage();
    })
  }
}