import { Markdown, MarkdownController } from '@luvi/lv-markdown-in';
import { CommonConstant } from 'base_common';

const BASE_URL = 'https://bbs.uestc.edu.cn';

// 定义解析后的片段类型
interface BBSegment {
  type: 'text' | 'image' | 'quote';
  content: string; // 文本内容、图片URL 或 引用主体内容
  quoteTitle?: string; // 仅 quote 类型使用，用于显示 "xxx 发表于 time"
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
  // 解析后的数据源
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
   * 优先级：Quote (BBCode & Markdown) > Image/Attach > Text
   */
  private parseContent() {
    if (!this.content) {
      this.segments = [];
      return;
    }

    const tempSegments: BBSegment[] = [];

    // 组合正则：
    // 1. 匹配 BBCode [quote]...[/quote] (Group 1)
    // 2. 匹配 Markdown 引用块 (以 > 开头的行，可能多行) (Group 2)
    const combinedRegex = /\[quote\]([\s\S]*?)\[\/quote\]|((?:^|\n)(?:>[^\n]*(?:\n|$))+)/g;

    let lastIndex = 0;
    let match: RegExpExecArray | null;

    while ((match = combinedRegex.exec(this.content)) !== null) {
      // 1. 处理匹配项之前的普通文本/图片
      if (match.index > lastIndex) {
        const textPart = this.content.substring(lastIndex, match.index);
        this.parseImagesAndText(textPart, tempSegments);
      }

      // 2. 处理匹配到的引用
      if (match[1]) {
        // --- Hit BBCode [quote] ---
        tempSegments.push(this.parseBBCodeQuote(match[1]));
      } else if (match[2]) {
        // --- Hit Markdown > Quote ---
        tempSegments.push(this.parseMarkdownQuote(match[2]));
      }

      lastIndex = combinedRegex.lastIndex;
    }

    // 3. 处理剩余的文本
    if (lastIndex < this.content.length) {
      const textPart = this.content.substring(lastIndex);
      this.parseImagesAndText(textPart, tempSegments);
    }

    this.segments = tempSegments;
  }

  /**
   * 解析 BBCode [quote]
   */
  private parseBBCodeQuote(raw: string): BBSegment {
    // 典型结构: [size=2][url=...][color=#999999]User 发表于 Time[/color][/url][/size]\nContent
    // 提取 [color]...[/color] 作为标题
    const headerRegex = /\[color=.*?\](.*?)\[\/color\]/;
    const headerMatch = headerRegex.exec(raw);
    let title = '';
    let body = raw;

    if (headerMatch) {
      title = headerMatch[1]; // "User 发表于 Time"
      // 移除包含 header 的 [size] 包裹层，简化显示
      const sizeRegex = /\[size=.*?\][\s\S]*?\[\/size\]\s*/;
      body = raw.replace(sizeRegex, '').trim();
    } else {
      body = raw.trim();
    }

    return {
      type: 'quote',
      content: body,
      quoteTitle: title
    };
  }

  /**
   * 解析 Markdown > 引用
   */
  private parseMarkdownQuote(raw: string): BBSegment {
    // 1. 拆分行并清理
    let lines = raw.trim().split('\n');
    // 去除每行开头的 > 和空格
    lines = lines.map(line => line.trim().replace(/^>\s?/, ''));

    if (lines.length === 0) {
      return { type: 'quote', content: '' };
    }

    let title = '';
    let body = '';

    // 2. 启发式提取标题
    // 如果第一行包含 "发表于"，则认为是元数据行
    // 示例: "> 熬苦瓜 发表于 [2026-01-03...](...)"
    if (lines[0].includes('发表于')) {
      title = lines[0];
      // 去除 Markdown 链接格式 [text](url) -> text，保留纯文本
      title = title.replace(/\[([^\]]+)\]\(.*?\)/g, '$1');

      // 剩余行作为内容
      body = lines.slice(1).join('\n').trim();
    } else {
      // 否则全部视为内容
      body = lines.join('\n').trim();
    }

    return {
      type: 'quote',
      content: body,
      quoteTitle: title
    };
  }

  /**
   * 解析普通文本中的 [attach] 和 [img]
   */
  private parseImagesAndText(text: string, results: BBSegment[]) {
    // 匹配 [attach]ID[/attach] 或 [img]URL[/img]
    const regex = /\[attach\](\d+)\[\/attach\]|\[img\](.*?)\[\/img\]/g;
    let lastIndex = 0;
    let match: RegExpExecArray | null;

    while ((match = regex.exec(text)) !== null) {
      // 文本片段
      if (match.index > lastIndex) {
        results.push({ type: 'text', content: text.substring(lastIndex, match.index) });
      }

      if (match[1]) {
        // [attach]: 转换为论坛附件链接
        const aid = match[1];
        const url = `${BASE_URL}/forum.php?mod=attachment&aid=${aid}`;
        results.push({ type: 'image', content: url });
      } else if (match[2]) {
        // [img]: 直接使用 URL
        results.push({ type: 'image', content: match[2] });
      }

      lastIndex = regex.lastIndex;
    }

    // 剩余文本
    if (lastIndex < text.length) {
      results.push({ type: 'text', content: text.substring(lastIndex) });
    }
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
        // 自定义轻量级渲染列表
        Column({ space: CommonConstant.SmallContainerInnerPadding }) {
          ForEach(this.segments, (item: BBSegment, index: number) => {
            if (item.type === 'quote') {
              // --- 引用组件 ---
              Column({ space: CommonConstant.SmallContainerInnerPadding }) {
                // 引用头部 (xxx 发表于 time)
                if (item.quoteTitle) {
                  Text(item.quoteTitle)
                    .fontSize(CommonConstant.TextSizeTiny)
                    .fontColor(this.quoteTextColor)
                    .fontWeight(FontWeight.Bold)
                }
                // 引用内容
                Text(item.content)
                  .fontSize(CommonConstant.TextSizeSmall)
                  .fontColor(this.quoteTextColor)
                  .maxLines(5)
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

            } else {
              // --- 文本组件 ---
              Text(item.content)
                .fontSize(this.textSize)
                .fontColor(this.textColor)
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