import { Chat, CommonConstant, DateUtil, StorageManager, UserAvatarUtil } from 'base_common';

interface ChatSegment {
  type: 'text' | 'image';
  content: string;
}

function parseChatContent(content: string): ChatSegment[] {
  const segments: ChatSegment[] = [];
  if (!content) {
    return segments;
  }
  const text = String(content);
  const regex = /\[mobcent_phiz=(.*?)\]/g;
  let lastIndex = 0;
  let match: RegExpExecArray | null;

  // 循环匹配所有表情
  while ((match = regex.exec(text)) !== null) {
    if (match.index > lastIndex) {
      segments.push({ type: 'text', content: text.substring(lastIndex, match.index) });
    }
    if (match[1]) {
      segments.push({ type: 'image', content: match[1] });
    }
    lastIndex = regex.lastIndex;
  }
  if (lastIndex < text.length) {
    segments.push({ type: 'text', content: text.substring(lastIndex) });
  }

  return segments;
}

@ComponentV2
export struct ChatBubble {
  @Param @Require chat: Chat;
  @Local imageSize: number = 150;

  @Computed
  get isMe(): boolean {
    return this.chat.sender === StorageManager.authModel?.uid;
  }

  @Builder
  ContentBuilder() {
    if (this.chat.type === 'image') {
      Image(this.chat.content)
        .width(this.imageSize)
        .borderRadius(CommonConstant.RadiusNormal)
        .autoResize(true)
        .constraintSize({ maxHeight: this.imageSize * 1.5 })
        .backgroundColor($r('app.color.second_window_background'))
    } else {
      Text() {
        ForEach(parseChatContent(this.chat.content), (segment: ChatSegment, index: number) => {
          if (segment.type === 'text') {
            Span(segment.content)
          } else if (segment.type === 'image') {
            ImageSpan(segment.content)
              .width(CommonConstant.IconSizeNormal)
              .height(CommonConstant.IconSizeNormal)
              .verticalAlign(ImageSpanAlignment.CENTER)
              .objectFit(ImageFit.Contain)
              .margin({
                left: CommonConstant.SmallContainerInnerPadding / 2,
                right: CommonConstant.SmallContainerInnerPadding / 2,
              })
          }
        }, (item: ChatSegment, index: number) => `${index}_${item.type}_${item.content.substring(0, 5)}`)
      }
      .fontSize(CommonConstant.TextSizeNormal)
      .fontColor(this.isMe ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
    }
  }

  build() {
    Column({ space: CommonConstant.NormalContainerInnerPadding }) {
      Row({ space: CommonConstant.NormalContainerInnerPadding }) {
        if (this.isMe) {
          // === 我发的消息 ===
          Blank()
          Row() {
            this.ContentBuilder()
          }
          .padding(this.chat.type === 'image' ? 0 : {
            left: CommonConstant.SmallContainerLRPadding,
            right: CommonConstant.SmallContainerLRPadding,
            top: CommonConstant.SmallContainerTBPadding,
            bottom: CommonConstant.SmallContainerTBPadding
          })
          .backgroundColor(this.chat.type === 'image' ? Color.Transparent : CommonConstant.ThemeColor)
          .borderRadius({
            topLeft: CommonConstant.RadiusUltraLarge,
            topRight: CommonConstant.RadiusTiny,
            bottomLeft: CommonConstant.RadiusUltraLarge,
            bottomRight: CommonConstant.RadiusUltraLarge
          })
          .constraintSize({ maxWidth: CommonConstant.AboveHalfPercent })

          Image(UserAvatarUtil.getAvatarUrl(this.chat.sender))
            .width(CommonConstant.IconSizeLarge)
            .height(CommonConstant.IconSizeLarge)
            .borderRadius(CommonConstant.RadiusRound)
        } else {
          // === 对方消息 ===
          Image(UserAvatarUtil.getAvatarUrl(this.chat.sender))
            .width(CommonConstant.IconSizeLarge)
            .height(CommonConstant.IconSizeLarge)
            .borderRadius(CommonConstant.RadiusRound)

          Row() {
            this.ContentBuilder()
          }
          .padding(this.chat.type === 'image' ? 0 : {
            left: CommonConstant.SmallContainerLRPadding,
            right: CommonConstant.SmallContainerLRPadding,
            top: CommonConstant.SmallContainerTBPadding,
            bottom: CommonConstant.SmallContainerTBPadding
          })
          .backgroundColor(this.chat.type === 'image' ? Color.Transparent : $r('app.color.second_window_background'))
          .borderRadius({
            topLeft: CommonConstant.RadiusTiny,
            topRight: CommonConstant.RadiusUltraLarge,
            bottomLeft: CommonConstant.RadiusUltraLarge,
            bottomRight: CommonConstant.RadiusUltraLarge
          })
          .constraintSize({ maxWidth: CommonConstant.AboveHalfPercent })

          Blank()
        }
      }
      .width(CommonConstant.FullPercent)
      .alignItems(VerticalAlign.Top)

      // === 时间显示 ===
      Row() {
        if (this.isMe) {
          Blank()
          Text(DateUtil.getRelativeTime(Number(this.chat.time)))
            .fontSize(CommonConstant.TextSizeTiny)
            .fontColor($r('sys.color.font_tertiary'))
            .margin({ right: CommonConstant.IconSizeLarge + CommonConstant.NormalContainerInnerPadding })
        } else {
          Text(DateUtil.getRelativeTime(Number(this.chat.time)))
            .fontSize(CommonConstant.TextSizeTiny)
            .fontColor($r('sys.color.font_tertiary'))
            .margin({ left: CommonConstant.IconSizeLarge + CommonConstant.NormalContainerInnerPadding })
          Blank()
        }
      }
      .width(CommonConstant.FullPercent)
    }
    .width(CommonConstant.FullPercent)
    .transition(
      TransitionEffect.OPACITY
        .combine(TransitionEffect.translate({ y: 20 }))
        .combine(TransitionEffect.scale({ x: 0.95, y: 0.95 }))
        .animation({ curve: CommonConstant.AnimationCurveSpring, duration: CommonConstant.AnimationDurationNormal })
    )
  }
}