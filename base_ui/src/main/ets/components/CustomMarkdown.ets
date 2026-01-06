import { Markdown, MarkdownController } from '@luvi/lv-markdown-in';
import { CommonConstant } from 'base_common';

const BASE_URL = 'https://bbs.uestc.edu.cn';

// 行内样式片段定义
interface InlineSpan {
  type: 'text' | 'image';
  text?: string;
  imageSrc?: string;
  isBold?: boolean;
  isItalic?: boolean;
  fontColor?: string;
  url?: string;
}

interface BBSegment {
  type: 'text' | 'image' | 'quote';
  content: string;
  quoteTitle?: string;
  spans?: InlineSpan[];
}

@ComponentV2
export struct CustomMarkdown {
  @Param @Require content: string;
  @Param controller: MarkdownController = new MarkdownController();
  @Param titleColor: ResourceColor = $r('sys.color.font_primary');
  @Param textColor: ResourceColor = $r('sys.color.font_primary');
  @Param textSize: number = CommonConstant.TextSizeNormal;
  @Param quoteBorderColor: ResourceColor = CommonConstant.ThemeColor;
  @Param quoteTextColor: ResourceColor = $r('sys.color.font_secondary');
  @Param quoteBgColor: ResourceColor = $r('app.color.tetertiary_window_background');
  @Param hyperlinkTextColor: ResourceColor = CommonConstant.ThemeColor;
  @Param useParallel: boolean = true;
  @Local segments: BBSegment[] = [];

  aboutToAppear(): void {
    if (!this.useParallel) {
      this.parseContent();
    }
    if (this.useParallel) {
      this.controller
        .setTitleColor(this.titleColor)
        .setTextColor(this.textColor)
        .setTextSize(this.textSize)
        .setQuoteBorderColor(this.quoteBorderColor)
        .setQuoteBackgroundColor(this.quoteBgColor)
        .setHyperlinkTextColor(this.hyperlinkTextColor)
    }
  }

  @Monitor('content')
  onContentChange() {
    if (!this.useParallel) {
      this.parseContent();
    }
  }

  private parseContent() {
    if (!this.content) {
      this.segments = [];
      return;
    }

    const tempSegments: BBSegment[] = [];
    const combinedRegex = /\[quote\]([\s\S]*?)\[\/quote\]|((?:^|\n)(?:>[^\n]*(?:\n|$))+)/g;

    let lastIndex = 0;
    let match: RegExpExecArray | null;

    while ((match = combinedRegex.exec(this.content)) !== null) {
      if (match.index > lastIndex) {
        this.parseImagesAndText(this.content.substring(lastIndex, match.index), tempSegments);
      }
      if (match[1]) {
        tempSegments.push(this.parseBBCodeQuote(match[1]));
      } else if (match[2]) {
        tempSegments.push(this.parseMarkdownQuote(match[2]));
      }
      lastIndex = combinedRegex.lastIndex;
    }

    if (lastIndex < this.content.length) {
      this.parseImagesAndText(this.content.substring(lastIndex), tempSegments);
    }

    this.segments = tempSegments;
  }

  private parseBBCodeQuote(raw: string): BBSegment {
    const headerRegex = /\[color=.*?\](.*?)\[\/color\]/;
    const headerMatch = headerRegex.exec(raw);
    let title = '';
    let body = raw;

    if (headerMatch) {
      title = headerMatch[1];
      const sizeRegex = /\[size=.*?\][\s\S]*?\[\/size\]\s*/;
      body = raw.replace(sizeRegex, '').trim();
    } else {
      body = raw.trim();
    }
    return { type: 'quote', content: body, quoteTitle: title };
  }

  private parseMarkdownQuote(raw: string): BBSegment {
    let lines = raw.trim().split('\n');
    lines = lines.map(line => line.trim().replace(/^>\s?/, ''));
    if (lines.length === 0) {
      return { type: 'quote', content: '' };
    }
    let title = '';
    let body = '';
    if (lines[0].includes('发表于')) {
      title = lines[0].replace(/\[([^\]]+)\]\(.*?\)/g, '$1');
      body = lines.slice(1).join('\n').trim();
    } else {
      body = lines.join('\n').trim();
    }
    return { type: 'quote', content: body, quoteTitle: title };
  }

  private parseImagesAndText(text: string, results: BBSegment[]) {
    const regex = /\[attach\](\d+)\[\/attach\]|\[img\](.*?)\[\/img\]/g;
    let lastIndex = 0;
    let match: RegExpExecArray | null;

    while ((match = regex.exec(text)) !== null) {
      if (match.index > lastIndex) {
        const rawText = text.substring(lastIndex, match.index);
        results.push({
          type: 'text',
          content: rawText,
          spans: this.parseInlineSpans(rawText)
        });
      }

      if (match[1]) {
        const url = `${BASE_URL}/forum.php?mod=attachment&aid=${match[1]}`;
        results.push({ type: 'image', content: url });
      } else if (match[2]) {
        results.push({ type: 'image', content: match[2] });
      }

      lastIndex = regex.lastIndex;
    }

    if (lastIndex < text.length) {
      const rawText = text.substring(lastIndex);
      results.push({
        type: 'text',
        content: rawText,
        spans: this.parseInlineSpans(rawText)
      });
    }
  }

  private parseInlineSpans(text: string): InlineSpan[] {
    const spans: InlineSpan[] = [];
    if (!text) {
      return spans;
    }

    const tagRegex = /(\[(?:\/)?(?:b|i|url|color)(?:=[^\]]*)?\]|\[mobcent_phiz=[^\]]*\])/i;
    const parts = text.split(tagRegex);

    let boldCount = 0;
    let italicCount = 0;
    const colorStack: string[] = [];
    const urlStack: string[] = [];

    for (let part of parts) {
      if (!part) {
        continue;
      }

      if (tagRegex.test(part)) {
        const lowerPart = part.toLowerCase();

        if (lowerPart.startsWith('[mobcent_phiz=')) {
          const phizUrl = part.substring(14, part.length - 1);
          spans.push({
            type: 'image',
            imageSrc: phizUrl
          });
          continue;
        }

        if (lowerPart === '[b]') {
          boldCount++;
        } else if (lowerPart === '[/b]') {
          boldCount =
            Math.max(0, boldCount - 1);
        } else if (lowerPart === '[i]') {
          italicCount++;
        } else if (lowerPart ===
          '[/i]') {
          italicCount =
            Math.max(0, italicCount - 1);
        } else if (lowerPart.startsWith('[color=')) {
          colorStack.push(part.substring(7,
            part.length - 1));
        } else if (lowerPart ===
          '[/color]') {
          colorStack.pop();
        } else if (lowerPart.startsWith('[url')) {
          if (lowerPart.includes('=')) {
            urlStack.push(part.substring(part.indexOf('=') + 1,
              part.length - 1));
          } else {
            urlStack.push('SELF');
          }
        } else if (lowerPart === '[/url]') {
          urlStack.pop();
        }

      } else {
        const currentUrlVal = urlStack.length > 0 ? urlStack[urlStack.length - 1] : undefined;
        const finalUrl = currentUrlVal === 'SELF' ? part : currentUrlVal;

        spans.push({
          type: 'text',
          text: part,
          isBold: boldCount > 0,
          isItalic: italicCount > 0,
          fontColor: colorStack.length > 0 ? colorStack[colorStack.length - 1] : undefined,
          url: finalUrl
        });
      }
    }
    return spans;
  }

  build() {
    Column() {
      if (this.useParallel) {
        Markdown({ text: this.content, controller: this.controller })
          .width(CommonConstant.FullPercent)
      } else {
        Column({ space: CommonConstant.SmallContainerInnerPadding }) {
          ForEach(this.segments, (item: BBSegment) => {
            if (item.type === 'quote') {
              Column({ space: CommonConstant.SmallContainerInnerPadding }) {
                if (item.quoteTitle) {
                  Text(item.quoteTitle)
                    .fontSize(CommonConstant.TextSizeTiny)
                    .fontColor(this.quoteTextColor)
                    .fontWeight(FontWeight.Bold)
                }
                Text(item.content)
                  .fontSize(CommonConstant.TextSizeSmall)
                  .fontColor(this.quoteTextColor)
              }
              .width(CommonConstant.FullPercent)
              .padding(CommonConstant.NormalContainerInnerPadding)
              .backgroundColor(this.quoteBgColor)
              .borderRadius(CommonConstant.RadiusSmall)
              .alignItems(HorizontalAlign.Start)
              .border({ width: { left: CommonConstant.BorderSizeLarge }, color: this.quoteBorderColor })

            } else if (item.type === 'image') {
              Image(item.content)
                .width(CommonConstant.FullPercent)
                .objectFit(ImageFit.Contain)
                .borderRadius(CommonConstant.RadiusNormal)
                .constraintSize({ maxHeight: 300 })
                .backgroundColor($r('app.color.tetertiary_window_background'))

            } else if (item.type === 'text') {
              Text() {
                ForEach(item.spans || [], (span: InlineSpan) => {
                  if (span.type === 'image' && span.imageSrc) {
                    ImageSpan(span.imageSrc)
                      .width(this.textSize * 1.5)
                      .height(this.textSize * 1.5)
                      .objectFit(ImageFit.Contain)
                      .verticalAlign(ImageSpanAlignment.CENTER)
                  } else {
                    // --- 核心修改：渲染文字链接样式 ---
                    Span(span.text)
                      .fontSize(this.textSize)
                      .fontColor(span.url ? this.hyperlinkTextColor : (span.fontColor || this.textColor))
                      .fontWeight(span.isBold ? FontWeight.Bold : FontWeight.Normal)
                      .fontStyle(span.isItalic ? FontStyle.Italic : FontStyle.Normal)
                      .decoration({
                        type: span.url ? TextDecorationType.Underline : TextDecorationType.None,
                        color: span.url ? this.hyperlinkTextColor : undefined,
                        style: span.url ? TextDecorationStyle.DASHED : undefined
                      })
                      .onClick(() => {
                        if (span.url) {
                          console.info('Link clicked:', span.url);
                          // RouterUtil.openWeb(span.url);
                        }
                      })
                  }
                })
              }
              .width(CommonConstant.FullPercent)
              .wordBreak(WordBreak.BREAK_ALL)
              .copyOption(CopyOptions.LocalDevice)
            }
          })
        }
        .width(CommonConstant.FullPercent)
        .alignItems(HorizontalAlign.Start)
      }
    }
    .padding({
      left: this.useParallel ? CommonConstant.NormalContainerInnerPadding : 0,
      right: this.useParallel ? CommonConstant.NormalContainerInnerPadding : 0
    })
    .width(CommonConstant.FullPercent)
    .alignItems(HorizontalAlign.Start)
  }
}