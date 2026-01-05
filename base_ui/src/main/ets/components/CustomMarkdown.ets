import { Markdown, MarkdownController } from '@luvi/lv-markdown-in';
import { CommonConstant } from 'base_common'; // 假设 RouterUtil 或其他工具用于处理链接跳转

const BASE_URL = 'https://bbs.uestc.edu.cn';

// --- 新增：行内样式片段定义 ---
interface InlineSpan {
  text: string;
  isBold: boolean;
  isItalic: boolean;
  fontColor?: string;
  url?: string; // 如果存在，说明是链接
}

// --- 修改：通用内容片段定义 ---
interface BBSegment {
  type: 'text' | 'image' | 'quote';
  content: string; // image/quote 的原始内容
  quoteTitle?: string; // quote 专用
  spans?: InlineSpan[]; // text 专用：富文本片段
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
    if (this.useParallel) {
      this.controller
        .setTitleColor(this.titleColor)
        .setTextColor(this.textColor)
        .setTextSize(this.textSize)
        .setQuoteBorderColor(this.quoteBorderColor)
        .setQuoteBackgroundColor(this.quoteBgColor)
        .setHyperlinkTextColor(this.hyperlinkTextColor)
    } else {
      this.parseContent();
    }
  }

  @Monitor('content')
  onContentChange() {
    if (!this.useParallel) {
      this.parseContent();
    }
  }

  /**
   * 核心解析逻辑
   * 1. 拆分 Quote (引用块)
   * 2. 拆分 Image/Attach (图片块)
   * 3. 解析剩余 Text 中的 BBCode 样式 (加粗/斜体/链接/颜色)
   */
  private parseContent() {
    if (!this.content) {
      this.segments = [];
      return;
    }

    const tempSegments: BBSegment[] = [];
    // 匹配 [quote]...[/quote] (BBCode) 或 > ... (Markdown)
    const combinedRegex = /\[quote\]([\s\S]*?)\[\/quote\]|((?:^|\n)(?:>[^\n]*(?:\n|$))+)/g;

    let lastIndex = 0;
    let match: RegExpExecArray | null;

    while ((match = combinedRegex.exec(this.content)) !== null) {
      // 1. 处理引用块之前的普通文本/图片
      if (match.index > lastIndex) {
        const textPart = this.content.substring(lastIndex, match.index);
        this.parseImagesAndText(textPart, tempSegments);
      }

      // 2. 处理引用块
      if (match[1]) {
        tempSegments.push(this.parseBBCodeQuote(match[1]));
      } else if (match[2]) {
        tempSegments.push(this.parseMarkdownQuote(match[2]));
      }

      lastIndex = combinedRegex.lastIndex;
    }

    // 3. 处理剩余部分
    if (lastIndex < this.content.length) {
      const textPart = this.content.substring(lastIndex);
      this.parseImagesAndText(textPart, tempSegments);
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

  /**
   * 解析图片标签，如果不是图片，则作为文本进一步解析行内样式
   */
  private parseImagesAndText(text: string, results: BBSegment[]) {
    // 匹配 [attach]ID[/attach] 或 [img]URL[/img]
    const regex = /\[attach\](\d+)\[\/attach\]|\[img\](.*?)\[\/img\]/g;
    let lastIndex = 0;
    let match: RegExpExecArray | null;

    while ((match = regex.exec(text)) !== null) {
      // 匹配项之前的文本 -> 解析为富文本片段
      if (match.index > lastIndex) {
        const rawText = text.substring(lastIndex, match.index);
        results.push({
          type: 'text',
          content: rawText,
          spans: this.parseInlineSpans(rawText) // 解析行内样式
        });
      }

      // 图片处理
      if (match[1]) {
        const url = `${BASE_URL}/forum.php?mod=attachment&aid=${match[1]}`;
        results.push({ type: 'image', content: url });
      } else if (match[2]) {
        results.push({ type: 'image', content: match[2] });
      }

      lastIndex = regex.lastIndex;
    }

    // 剩余文本
    if (lastIndex < text.length) {
      const rawText = text.substring(lastIndex);
      results.push({
        type: 'text',
        content: rawText,
        spans: this.parseInlineSpans(rawText) // 解析行内样式
      });
    }
  }

  /**
   * --- 新增核心方法 ---
   * 解析行内 BBCode 样式: [b], [i], [url], [color]
   */
  private parseInlineSpans(text: string): InlineSpan[] {
    const spans: InlineSpan[] = [];
    if (!text) {
      return spans;
    }

    // 正则拆分 token: 匹配标签 [b], [/b], [color=xxx], [/color] 等
    // 捕获组会包含在 split 结果中
    const tagRegex = /(\[(?:\/)?(?:b|i|url|color)(?:=[^\]]*)?\])/gi;
    const parts = text.split(tagRegex);

    // 样式状态栈
    let boldCount = 0;
    let italicCount = 0;
    const colorStack: string[] = [];
    const urlStack: string[] = []; // 存储 url 地址，若为 'SELF' 表示链接就是文本本身

    for (let part of parts) {
      if (!part) {
        continue;
      }

      // 判断是否是标签
      if (tagRegex.test(part)) {
        const lowerPart = part.toLowerCase();

        // Bold [b] [/b]
        if (lowerPart === '[b]') {
          boldCount++;
        } else if (lowerPart === '[/b]') {
          boldCount = Math.max(0, boldCount - 1);
        }
        // Italic [i] [/i]
        else if (lowerPart === '[i]') {
          italicCount++;
        } else if (lowerPart === '[/i]') {
          italicCount = Math.max(0, italicCount - 1);
        }
        // Color [color=xxx] [/color]
        else if (lowerPart.startsWith('[color=')) {
          const colorVal = part.substring(7, part.length - 1);
          colorStack.push(colorVal);
        } else if (lowerPart === '[/color]') {
          colorStack.pop();
        }
        // URL [url] [url=xxx] [/url]
        else if (lowerPart.startsWith('[url')) {
          if (lowerPart.includes('=')) {
            // [url=http://...]
            const urlVal = part.substring(part.indexOf('=') + 1, part.length - 1);
            urlStack.push(urlVal);
          } else {
            // [url] (文本即链接)
            urlStack.push('SELF');
          }
        } else if (lowerPart === '[/url]') {
          urlStack.pop();
        }
      } else {
        // 是普通文本，应用当前样式状态生成 Span
        const currentUrlVal = urlStack.length > 0 ? urlStack[urlStack.length - 1] : undefined;
        // 如果是 'SELF' 类型链接，则文本本身就是 URL
        const finalUrl = currentUrlVal === 'SELF' ? part : currentUrlVal;

        spans.push({
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
        Markdown({
          text: this.content,
          controller: this.controller
        })
          .width(CommonConstant.FullPercent)
      } else {
        // 轻量级渲染列表
        Column({ space: CommonConstant.SmallContainerInnerPadding }) {
          ForEach(this.segments, (item: BBSegment, index: number) => {
            if (item.type === 'quote') {
              // --- 引用组件 ---
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
                  .maxLines(10)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .wordBreak(WordBreak.BREAK_ALL)
              }
              .width(CommonConstant.FullPercent)
              .padding(CommonConstant.NormalContainerInnerPadding)
              .backgroundColor(this.quoteBgColor)
              .borderRadius(CommonConstant.RadiusSmall)
              .alignItems(HorizontalAlign.Start)
              .border({
                width: { left: CommonConstant.BorderSizeLarge },
                color: this.quoteBorderColor
              })

            } else if (item.type === 'image') {
              // --- 图片组件 ---
              Image(item.content)
                .width(CommonConstant.FullPercent)
                .objectFit(ImageFit.Contain)
                .borderRadius(CommonConstant.RadiusNormal)
                .alignSelf(ItemAlign.Center)
                .constraintSize({ maxHeight: 300 })
                .backgroundColor($r('app.color.tetertiary_window_background'))
                .onClick(() => {
                  // 可选：实现点击查看大图
                })

            } else if (item.type === 'text') {
              // --- 富文本组件 (支持 Span) ---
              Text() {
                ForEach(item.spans || [], (span: InlineSpan) => {
                  Span(span.text)
                    .fontSize(this.textSize)
                    .fontColor(span.url ? this.hyperlinkTextColor : (span.fontColor || this.textColor))
                    .fontWeight(span.isBold ? FontWeight.Bold : FontWeight.Normal)
                    .fontStyle(span.isItalic ? FontStyle.Italic : FontStyle.Normal)
                    .onClick(() => {
                      if (span.url) {
                        // 处理链接跳转，假设有一个处理工具
                        // console.info('Jump to:', span.url);
                        // RouterUtil.openWeb(span.url);
                      }
                    })
                })
              }
              .width(CommonConstant.FullPercent)
              .wordBreak(WordBreak.BREAK_ALL)
              .copyOption(CopyOptions.LocalDevice)
            }
          }, (item: BBSegment, index: number) => index.toString() + item.type)
        }
        .width(CommonConstant.FullPercent)
        .alignItems(HorizontalAlign.Start)
      }
    }
    .padding(CommonConstant.NormalContainerInnerPadding)
    .width(CommonConstant.FullPercent)
    .alignItems(HorizontalAlign.Start)
  }
}