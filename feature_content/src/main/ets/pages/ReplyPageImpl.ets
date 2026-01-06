import { ReplyPageVM } from '../viewmodels/ReplyPageVM';
import { KeyboardAvoidMode } from '@kit.ArkUI';
import { AppUtil } from '@pura/harmony-utils';
import { CommonConstant, RouterUtil } from 'base_common';
import { CustomAtPanel, CustomFacePanel } from 'base_ui';
import { ImagePicker } from 'feature_post';

@ComponentV2
export struct ReplyPageImpl {
  @Local vm: ReplyPageVM = new ReplyPageVM();
  @Local isShow: boolean = false;

  @Computed
  get placeHolder(): ResourceStr {
    return $r('app.string.ReplyPage_placeholder');
  }

  private closeDialog() {
    AppUtil.getUIContext().animateTo({
      duration: CommonConstant.AnimationDurationNormal,
      curve: Curve.EaseOut,
      onFinish: () => {
        RouterUtil.pop(undefined, false)
      }
    }, () => {
      this.isShow = false;
    });
  }

  async send() {
    const success = await this.vm.sendReply();
    if (success) {
      this.closeDialog();
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        if (this.isShow) {
          Column()
            .width(CommonConstant.FullPercent)
            .height(CommonConstant.FullPercent)
            .backgroundColor($r('app.color.mask_color'))
            .onClick(() => this.closeDialog())
            .transition(TransitionEffect.OPACITY.animation({
              duration: CommonConstant.AnimationDurationNormal,
              curve: Curve.EaseOut
            }))
        }
        Column() {
          Row() {
            Text($r('app.string.ReplyPage_cancel'))
              .fontColor($r('sys.color.font_secondary'))
              .fontSize(CommonConstant.TextSizeNormal)
              .onClick(() => this.closeDialog())

            Text($r('app.string.ReplyPage_reply'))
              .fontWeight(FontWeight.Bold)
              .fontSize(CommonConstant.TextSizeLarge)

            Button($r('app.string.ReplyPage_send'))
              .type(ButtonType.Capsule)
              .height(CommonConstant.IconSizeNormal)
              .backgroundColor(CommonConstant.ThemeColor)
              .fontColor($r('sys.color.font_on_primary'))
              .fontSize(CommonConstant.TextSizeSmall)
              .onClick(() => this.send())
              .enabled(!this.vm.uploadedImages.some(i => i.isLoading) || !this.vm.replyContent.trim())
              .opacity(this.vm.uploadedImages.some(i => i.isLoading) || !this.vm.replyContent.trim() ? 0.5 : 1)
          }
          .width(CommonConstant.FullPercent)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({
            left: CommonConstant.NormalContainerLRPadding,
            right: CommonConstant.NormalContainerLRPadding,
            top: CommonConstant.NormalContainerTBPadding,
            bottom: CommonConstant.NormalContainerTBPadding
          })

          Divider().color($r('sys.color.font_tertiary')).opacity(0.5)

          // --- 输入区域 (可滚动) ---
          Column() {
            TextArea({
              text: this.vm.replyContent,
              placeholder: this.placeHolder,
              controller: this.vm.controller
            })
              .id('reply_input')
              .width(CommonConstant.FullPercent)
              .layoutWeight(1) // 占据剩余空间
              .backgroundColor(Color.Transparent)
              .fontSize(CommonConstant.TextSizeNormal)
              .padding(CommonConstant.NormalContainerInnerPadding)
              .enableKeyboardOnFocus(true)
              .onChange((value) => this.vm.replyContent = value)
              .onFocus(() => {
                AppUtil.getUIContext().animateTo({ duration: CommonConstant.AnimationDurationNormal }, () => {
                  this.vm.isInputting = true;
                  this.vm.isShowFace = false;
                  this.vm.isShowAt = false;
                  this.vm.isInsertImageMode = false;
                });
              })
              .onTextSelectionChange((start, end) => {
                this.vm.updateContentSelection(start, end);
              })
          }
          .layoutWeight(1)
          .constraintSize({ maxHeight: this.vm.window.windowHeight / 2 })

          if (this.vm.uploadedImages.length > 0 || this.vm.isInsertImageMode) {
            Column() {
              ImagePicker({ vm: this.vm })
            }
            .width(CommonConstant.FullPercent)
            .padding({
              left: CommonConstant.NormalContainerInnerPadding,
              right: CommonConstant.NormalContainerInnerPadding,
              bottom: CommonConstant.NormalContainerInnerPadding
            })
            .transition(TransitionEffect.OPACITY.animation({ duration: CommonConstant.AnimationDurationNormal }))
          }

          // --- 底部工具栏 ---
          Row({ space: CommonConstant.NormalContainerInnerPadding }) {
            // 图片按钮
            SymbolGlyph($r('sys.symbol.picture'))
              .fontSize(CommonConstant.IconSizeNormal)
              .fontColor(this.vm.isInsertImageMode ? [CommonConstant.ThemeColor] : [$r('sys.color.font_primary')])
              .onClick(() => {
                AppUtil.getUIContext().animateTo({ duration: CommonConstant.AnimationDurationNormal }, () => {
                  this.vm.isInsertImageMode = !this.vm.isInsertImageMode;
                  this.vm.isShowFace = false;
                  this.vm.isShowAt = false;
                  if (this.vm.isInsertImageMode) {
                    this.vm.closeKeyboard();
                    this.vm.isInputting = false;
                  }
                });
              })

            // 表情按钮
            SymbolGlyph($r('sys.symbol.capture_smiles'))
              .fontSize(CommonConstant.IconSizeNormal)
              .fontColor(this.vm.isShowFace ? [CommonConstant.ThemeColor] : [$r('sys.color.font_primary')])
              .onClick(() => {
                AppUtil.getUIContext().animateTo({ duration: CommonConstant.AnimationDurationNormal }, () => {
                  this.vm.isShowFace = !this.vm.isShowFace;
                  this.vm.isShowAt = false;
                  this.vm.isInsertImageMode = false;
                  if (this.vm.isShowFace) {
                    this.vm.closeKeyboard();
                    this.vm.isInputting = false;
                  } else {
                    focusControl.requestFocus('reply_input');
                  }
                });
              })

            // @按钮
            SymbolGlyph($r('sys.symbol.at'))
              .fontSize(CommonConstant.IconSizeNormal)
              .fontColor(this.vm.isShowAt ? [CommonConstant.ThemeColor] : [$r('sys.color.font_primary')])
              .onClick(() => {
                AppUtil.getUIContext().animateTo({ duration: CommonConstant.AnimationDurationNormal }, () => {
                  this.vm.isShowAt = !this.vm.isShowAt;
                  this.vm.isShowFace = false;
                  this.vm.isInsertImageMode = false;
                  if (this.vm.isShowAt) {
                    this.vm.closeKeyboard();
                    this.vm.isInputting = false;
                  } else {
                    focusControl.requestFocus('reply_input');
                  }
                });
              })

            Blank()

            Row({ space: CommonConstant.SmallContainerInnerPadding }) {
              Checkbox()
                .select(this.vm.isAnonymous)
                .onChange((val) => this.vm.isAnonymous = val)
                .selectedColor(CommonConstant.ThemeColor)
                .width(CommonConstant.TextSizeNormal)
                .height(CommonConstant.TextSizeNormal)
              Text($r('app.string.ReplyPage_anonymous'))
                .fontSize(CommonConstant.TextSizeSmall)
                .fontColor($r('sys.color.font_secondary'))
            }
          }
          .width(CommonConstant.FullPercent)
          .padding({
            left: CommonConstant.NormalContainerLRPadding,
            right: CommonConstant.NormalContainerLRPadding,
            top: CommonConstant.NormalContainerTBPadding,
            bottom: CommonConstant.NormalContainerTBPadding
          })
          .backgroundColor($r('app.color.second_window_background'))

          if (this.vm.isShowFace) {
            CustomFacePanel({
              vm: this.vm,
              onFaceClick: (url): void => this.vm.insertFace(url)
            })
              .transition(TransitionEffect.move(TransitionEdge.BOTTOM)
                .animation({ duration: CommonConstant.AnimationDurationNormal }))
          }

          if (this.vm.isShowAt) {
            CustomAtPanel({
              vm: this.vm,
              onAtUserClick: (user): void => this.vm.insertAtUser(user)
            })
              .transition(TransitionEffect.move(TransitionEdge.BOTTOM)
                .animation({ duration: CommonConstant.AnimationDurationNormal }))
          }

          Column()
            .width(CommonConstant.FullPercent)
            .height(this.vm.window.windowBottomPadding)
            .backgroundColor($r('app.color.second_window_background'))
        }
        .width(CommonConstant.FullPercent)
        .constraintSize({
          maxWidth: this.vm.isTabletView ? this.vm.window.windowWidth / 2 : CommonConstant.FullPercent
        })
        .backgroundColor($r('app.color.start_window_background'))
        .borderRadius({ topLeft: CommonConstant.RadiusUltraLarge, topRight: CommonConstant.RadiusUltraLarge })
        .clip(true)
        .shadow(ShadowStyle.OUTER_DEFAULT_MD)
        .transition(TransitionEffect.move(TransitionEdge.BOTTOM).animation({
          duration: CommonConstant.AnimationDurationNormal,
          curve: CommonConstant.AnimationCurveSpring
        }))
        .visibility(this.isShow ? Visibility.Visible : Visibility.Hidden)
      }
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
      .alignContent(Alignment.Bottom)
    }
    .mode(NavDestinationMode.DIALOG)
    .hideTitleBar(true)
    .backgroundColor(Color.Transparent)
    .onReady((context: NavDestinationContext) => {
      const params = context.pathInfo.param as Record<string, Object>;
      if (params && params['threadId']) {
        this.vm.init(params['threadId'] as number);
      }

      AppUtil.getUIContext().animateTo({
        duration: CommonConstant.AnimationDurationNormal,
        curve: CommonConstant.AnimationCurveSpring
      }, () => {
        this.isShow = true;
      });

      setTimeout(() => {
        focusControl.requestFocus('reply_input');
        this.vm.isInputting = true;
      }, CommonConstant.AnimationDurationNormal);
    })
    .onShown(() => {
      this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE_WITH_CARET)
    })
    .onHidden(() => {
      this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET)
    })
  }
}