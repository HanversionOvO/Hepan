import { CommonConstant } from 'base_common';
import { FloatButton } from 'base_ui';
import { ChatPageVM } from '../viewmodels/ChatPageVM';

@ComponentV2
export struct ChatBottomBar {
  @Param @Require vm: ChatPageVM;
  @Param controller: RichEditorController = this.vm.richEditorController;
  @Local hasContent: boolean = false;
  @Event onFaceClick: () => void;
  @Event onFileClick: () => void

  checkContent() {
    let hasTextOrImage = false;
    const spans = this.controller.getSpans();

    for (const span of spans) {
      const textSpan = span as RichEditorTextSpanResult;

      if (typeof textSpan.value === 'string') {
        if (textSpan.value.trim().length > 0) {
          hasTextOrImage = true;
          break;
        }
      } else {
        hasTextOrImage = true;
        break;
      }
    }
    this.hasContent = hasTextOrImage;
  }

  build() {
    Row({ space: CommonConstant.NormalContainerInnerPadding }) {
      FloatButton({
        isFloating: true,
        floatIcon: $r('sys.symbol.picture')
      })
        .onClick(() => {
          this.onFileClick();
        })

      Row({ space: CommonConstant.NormalContainerInnerPadding }) {
        RichEditor({
          controller: this.controller
        })
          .constraintSize({
            minHeight: CommonConstant.IconSizeLarge,
            maxHeight: CommonConstant.IconSizeLarge * 3
          })
          .backgroundColor(Color.Transparent)
          .barState(BarState.Off)
          .placeholder($r('app.string.ChatPage_send_placeholder'), {
            font: {
              size: CommonConstant.TextSizeNormal
            }
          })
          .caretColor(CommonConstant.ThemeColor)
          .layoutWeight(1)
          .onReady(() => {
            this.controller.setTypingStyle({
              fontSize: CommonConstant.TextSizeNormal,
              fontColor: $r('sys.color.font_primary')
            })

            this.checkContent();
          })
          .onDidChange(() => {
            this.checkContent();
          })

        if (this.hasContent) {
          Row() {
            SymbolGlyph($r('sys.symbol.paperplane'))
              .fontSize(CommonConstant.TextSizeLarge)
              .fontWeight(FontWeight.Bold)
              .fontColor([$r('sys.color.font_on_primary')])
          }
          .width(CommonConstant.IconSizeNormal)
          .height(CommonConstant.IconSizeNormal)
          .borderRadius(CommonConstant.RadiusRound)
          .backgroundColor(CommonConstant.ThemeColor)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .transition(
            TransitionEffect.OPACITY
              .combine(TransitionEffect.scale({ x: 0.5, y: 0.5 }))
              .animation({
                duration: CommonConstant.AnimationDurationNormal,
                curve: CommonConstant.AnimationCurveSpring
              })
          )
          .onClick(async () => {
            const spans = this.controller.getSpans();
            this.controller.deleteSpans();
            this.checkContent();

            let msgContent = '';

            for (const span of spans) {
              const textSpan = span as RichEditorTextSpanResult;
              const imageSpan = span as RichEditorImageSpanResult;

              if (imageSpan.imageStyle) {
                if (imageSpan.valueResourceStr && typeof imageSpan.valueResourceStr === 'string') {
                  msgContent += `[mobcent_phiz=${imageSpan.valueResourceStr}]`;
                }
              } else {
                if (typeof textSpan.value === 'string') {
                  msgContent += textSpan.value;
                }
              }
            }

            if (msgContent.length > 0) {
              await this.vm.sendMessage({
                type: 'text',
                content: msgContent
              });
            }
          })
        }
      }
      .layoutWeight(1)
      .animation({
        duration: CommonConstant.AnimationDurationNormal,
        curve: CommonConstant.AnimationCurveSpring
      })
      .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
      .borderRadius(CommonConstant.IconSizeLarge / 2)
      .padding({ right: CommonConstant.SmallContainerInnerPadding })

      FloatButton({
        isFloating: true,
        floatIcon: $r('sys.symbol.capture_smiles')
      })
        .onClick(() => {
          this.onFaceClick();
        })
    }
    .width(CommonConstant.FullPercent)
    .justifyContent(FlexAlign.SpaceBetween)
    .transition(TransitionEffect.move(TransitionEdge.BOTTOM).combine(TransitionEffect.opacity(0)))
    .animation({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring })
    .padding({
      left: CommonConstant.PageLRPadding,
      right: CommonConstant.PageLRPadding
    })
    .alignItems(VerticalAlign.Bottom)
  }
}