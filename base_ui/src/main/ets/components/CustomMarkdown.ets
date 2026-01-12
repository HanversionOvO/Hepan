import { AppPreferenceKeys, CommonConstant, PreferenceUtil, UrlUtil } from 'base_common';
import { util } from '@kit.ArkTS';
import { AppUtil } from '@pura/harmony-utils';
import resourceManager from '@ohos.resourceManager';

interface InlineSpan {
  type: 'text' | 'image';
  text?: string;
  imageSrc?: string;
  isBold?: boolean;
  isItalic?: boolean;
  isStrikethrough?: boolean;
  isUnderline?: boolean;
  fontColor?: string;
  url?: string;
}

interface BBSegment {
  type: 'text' | 'image' | 'quote' | 'heading' | 'divider' | 'code' | 'task' | 'list';
  content: string;
  quoteTitle?: string;
  spans?: InlineSpan[];
  headingLevel?: number;
  taskChecked?: boolean;
  listOrdered?: boolean;
  listIndex?: number;
}

interface FaceItem {
  icon_url: string;
  icon_type: string;
  icon_index: number;
}

interface FaceCollection {
  base_url: string;
  collections: FaceItem[];
}

interface TaskLine {
  checked: boolean;
  text: string;
}

interface ListLine {
  ordered: boolean;
  index: number;
  text: string;
}

@ComponentV2
export struct CustomMarkdown {
  @Param @Require content: string;
  @Param titleColor: ResourceColor = $r('sys.color.font_primary');
  @Param textColor: ResourceColor = $r('sys.color.font_primary');
  @Param textSize: number = CommonConstant.TextSizeNormal;
  @Param quoteBorderColor: ResourceColor = CommonConstant.ThemeColor;
  @Param quoteTextColor: ResourceColor = $r('sys.color.font_secondary');
  @Param quoteBgColor: ResourceColor = $r('app.color.tetertiary_window_background');
  @Param hyperlinkTextColor: ResourceColor = CommonConstant.ThemeColor;
  @Param useMarkDown: boolean = true;
  @Local segments: BBSegment[] = [];
  @Local baseUrl: string = CommonConstant.BASE_URL;
  private faceRelativeMap: Map<string, string> = new Map();
  private faceLoaded: boolean = false;

  aboutToAppear(): void {
    this.loadBaseUrl();
    this.loadFaceData();
    this.parseContent();
  }

  @Monitor('content')
  onContentChange() {
    this.parseContent();
  }

  private loadBaseUrl() {
    const storedBaseUrl = PreferenceUtil.read<string>(AppPreferenceKeys.prefName, (pref) => {
      return pref.getSync(AppPreferenceKeys.baseUrl, CommonConstant.BASE_URL) as string;
    }, CommonConstant.BASE_URL);
    this.baseUrl = storedBaseUrl ? storedBaseUrl : CommonConstant.BASE_URL;
  }

  private async loadFaceData() {
    if (this.faceLoaded) {
      return;
    }
    try {
      const context = AppUtil.getContext();
      const resManager: resourceManager.ResourceManager = context.resourceManager;
      let content: Uint8Array;
      try {
        content = await resManager.getRawFileContent('new_faces.json');
      } catch (error) {
        try {
          content = await resManager.getRawFileContent('faces_new.json');
        } catch (innerError) {
          content = await resManager.getRawFileContent('faces.json');
        }
      }
      const textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      const jsonString = textDecoder.decodeWithStream(content);
      const data = JSON.parse(jsonString) as FaceCollection[];
      data.forEach((collection) => {
        const basePath = collection.base_url;
        collection.collections.forEach((face) => {
          const key = `${face.icon_type}:${face.icon_index}`;
          const relativePath = UrlUtil.buildUrl(basePath, face.icon_url);
          this.faceRelativeMap.set(key, relativePath);
        });
      });
      this.faceLoaded = true;
      this.parseContent();
    } catch (error) {
      this.faceLoaded = true;
    }
  }

  private parseContent() {
    if (!this.content) {
      this.segments = [];
      return;
    }

    const tempSegments: BBSegment[] = [];
    const codeRegex = /```([^\n]*)\n([\s\S]*?)```/g;
    let lastIndex = 0;
    let codeMatch: RegExpExecArray | null;

    while ((codeMatch = codeRegex.exec(this.content)) !== null) {
      if (codeMatch.index > lastIndex) {
        this.parseNonCodeContent(this.content.substring(lastIndex, codeMatch.index), tempSegments);
      }
      const codeContent = codeMatch[2] || '';
      tempSegments.push({
        type: 'code',
        content: codeContent.replace(/\s+$/, '')
      });
      lastIndex = codeRegex.lastIndex;
    }

    if (lastIndex < this.content.length) {
      this.parseNonCodeContent(this.content.substring(lastIndex), tempSegments);
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
    if (lines.length > 1) {
      title = lines[0];
      body = lines.slice(1).join('\n').trim();
    } else {
      body = lines[0].trim();
    }
    return { type: 'quote', content: body, quoteTitle: title };
  }

  private parseNonCodeContent(text: string, results: BBSegment[]) {
    if (!text) {
      return;
    }

    const combinedRegex = /\[quote\]([\s\S]*?)\[\/quote\]|((?:^|\n)(?:>[^\n]*(?:\n|$))+)/g;
    let lastIndex = 0;
    let match: RegExpExecArray | null;

    while ((match = combinedRegex.exec(text)) !== null) {
      if (match.index > lastIndex) {
        this.parseTextLines(text.substring(lastIndex, match.index), results);
      }
      if (match[1]) {
        results.push(this.parseBBCodeQuote(match[1]));
      } else if (match[2]) {
        results.push(this.parseMarkdownQuote(match[2]));
      }
      lastIndex = combinedRegex.lastIndex;
    }

    if (lastIndex < text.length) {
      this.parseTextLines(text.substring(lastIndex), results);
    }
  }

  private parseTextLines(text: string, results: BBSegment[]) {
    if (!this.useMarkDown) {
      this.parseImagesAndText(text, results);
      return;
    }

    const lines = text.split('\n');
    let buffer = '';

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      const trimmed = line.trim();
      const trimmedStart = line.trimStart();
      const headingLevel = this.getHeadingLevel(trimmedStart);
      const taskItem = this.parseTaskLine(line);
      const listItem = taskItem ? null : this.parseListLine(line);
      const isDivider = this.isDividerLine(trimmed);

      if (headingLevel > 0) {
        this.flushTextBlock(buffer, results);
        buffer = '';
        results.push({
          type: 'heading',
          content: trimmedStart.substring(headingLevel).trim(),
          headingLevel: headingLevel
        });
        continue;
      }

      if (isDivider) {
        this.flushTextBlock(buffer, results);
        buffer = '';
        results.push({ type: 'divider', content: '' });
        continue;
      }

      if (taskItem) {
        this.flushTextBlock(buffer, results);
        buffer = '';
        results.push({
          type: 'task',
          content: taskItem.text,
          taskChecked: taskItem.checked,
          spans: this.parseInlineSpans(taskItem.text)
        });
        continue;
      }

      if (listItem) {
        this.flushTextBlock(buffer, results);
        buffer = '';
        results.push({
          type: 'list',
          content: listItem.text,
          listOrdered: listItem.ordered,
          listIndex: listItem.index,
          spans: this.parseInlineSpans(listItem.text)
        });
        continue;
      }

      buffer += line;
      if (i < lines.length - 1) {
        buffer += '\n';
      }
    }

    this.flushTextBlock(buffer, results);
  }

  private flushTextBlock(text: string, results: BBSegment[]) {
    if (!text) {
      return;
    }
    this.parseImagesAndText(text, results);
  }

  private getHeadingLevel(line: string): number {
    if (!this.useMarkDown) {
      return 0;
    }
    let level = 0;
    while (level < line.length && line[level] === '#') {
      level++;
      if (level >= 6) {
        break;
      }
    }
    if (level === 0) {
      return 0;
    }
    if (line.length === level) {
      return level;
    }
    if (line.length > level && line[level] === ' ') {
      return level;
    }
    if (line[level] === '#') {
      return 0;
    }
    return level;
  }

  private isDividerLine(trimmed: string): boolean {
    if (!this.useMarkDown) {
      return false;
    }
    if (trimmed.length < 3) {
      return false;
    }
    return /^(-{3,}|\*{3,}|_{3,})$/.test(trimmed);
  }

  private parseTaskLine(line: string): TaskLine | null {
    if (!this.useMarkDown) {
      return null;
    }
    const match = /^\s*(?:-|\*)\s+\[( |x|X)\]\s+(.*)$/.exec(line);
    if (!match) {
      return null;
    }
    return {
      checked: match[1].toLowerCase() === 'x',
      text: match[2].trim()
    };
  }

  private parseListLine(line: string): ListLine | null {
    if (!this.useMarkDown) {
      return null;
    }
    const orderedMatch = /^\s*(\d+)\.\s+(.*)$/.exec(line);
    if (orderedMatch) {
      return {
        ordered: true,
        index: Number(orderedMatch[1]),
        text: orderedMatch[2].trim()
      };
    }
    const unorderedMatch = /^\s*(?:-|\*|\+)\s+(.*)$/.exec(line);
    if (unorderedMatch) {
      return {
        ordered: false,
        index: 0,
        text: unorderedMatch[1].trim()
      };
    }
    return null;
  }

  private parseImagesAndText(text: string, results: BBSegment[]) {
    if (!text) {
      return;
    }

    const regex = this.useMarkDown
      ? /!\[([^\]]*)\]\(([^)]+)\)|\[attach\](\d+)\[\/attach\]|\[img\](.*?)\[\/img\]/g
      : /\[attach\](\d+)\[\/attach\]|\[img\](.*?)\[\/img\]/g;

    let lastIndex = 0;
    let match: RegExpExecArray | null;
    let buffer = '';

    while ((match = regex.exec(text)) !== null) {
      if (match.index > lastIndex) {
        buffer += text.substring(lastIndex, match.index);
      }

      if (this.useMarkDown && match[1] !== undefined && match[2] !== undefined) {
        const alt = match[1];
        const url = match[2];
        const faceUrl = this.resolveFaceUrl(url, alt);
        if (faceUrl) {
          buffer += `[mobcent_phiz=${faceUrl}]`;
        } else if (this.isEmojiToken(url, alt)) {
          buffer += `![${alt}](${url})`;
        } else {
          this.flushText(buffer, results);
          buffer = '';
          results.push({ type: 'image', content: this.normalizeImageUrl(url) });
        }
      } else if (match[3]) {
        this.flushText(buffer, results);
        buffer = '';
        results.push({ type: 'image', content: this.buildAttachmentUrl(match[3]) });
      } else if (match[4]) {
        this.flushText(buffer, results);
        buffer = '';
        results.push({ type: 'image', content: this.normalizeImageUrl(match[4]) });
      } else if (!this.useMarkDown && match[1]) {
        this.flushText(buffer, results);
        buffer = '';
        results.push({ type: 'image', content: this.buildAttachmentUrl(match[1]) });
      } else if (!this.useMarkDown && match[2]) {
        this.flushText(buffer, results);
        buffer = '';
        results.push({ type: 'image', content: this.normalizeImageUrl(match[2]) });
      }

      lastIndex = regex.lastIndex;
    }

    if (lastIndex < text.length) {
      buffer += text.substring(lastIndex);
    }

    this.flushText(buffer, results);
  }

  private flushText(text: string, results: BBSegment[]) {
    if (!text) {
      return;
    }
    results.push({
      type: 'text',
      content: text,
      spans: this.parseInlineSpans(text)
    });
  }

  private isEmojiToken(iconType: string, iconIndex: string): boolean {
    const typeValue = iconType.trim();
    if (!typeValue) {
      return false;
    }
    if (typeValue.includes('/') || typeValue.includes('.') || typeValue.includes(':')) {
      return false;
    }
    if (!/^[a-zA-Z0-9_-]+$/.test(typeValue)) {
      return false;
    }
    const indexValue = Number(iconIndex);
    return Number.isFinite(indexValue);
  }

  private resolveFaceUrl(iconType: string, iconIndex: string): string {
    const indexValue = Number(iconIndex);
    if (!Number.isFinite(indexValue)) {
      return '';
    }
    const key = `${iconType}:${indexValue}`;
    const relative = this.faceRelativeMap.get(key);
    if (relative) {
      return UrlUtil.buildUrl(this.baseUrl, relative);
    }
    if (iconType !== 'a') {
      const fallback = this.faceRelativeMap.get(`a:${indexValue}`);
      if (fallback) {
        return UrlUtil.buildUrl(this.baseUrl, fallback);
      }
    }
    return '';
  }

  private parseInlineSpans(text: string): InlineSpan[] {
    return this.useMarkDown ? this.parseMarkdownInlineSpans(text) : this.parseBBCodeInlineSpans(text);
  }

  private parseBBCodeInlineSpans(text: string): InlineSpan[] {
    const spans: InlineSpan[] = [];
    if (!text) {
      return spans;
    }

    const tagRegex = /(\[(?:\/)?(?:b|i|u|url|color)(?:=[^\]]*)?\]|\[mobcent_phiz=[^\]]*\]|\[[a-zA-Z0-9_]+:\d+\])/i;
    const parts = text.split(tagRegex);

    let boldCount = 0;
    let italicCount = 0;
    let underlineCount = 0;
    const colorStack: string[] = [];
    const urlStack: string[] = [];

    for (let part of parts) {
      if (!part) {
        continue;
      }

      if (tagRegex.test(part)) {
        const lowerPart = part.toLowerCase();

        const emojiMatch = /^\[([a-zA-Z0-9_]+):(\d+)\]$/.exec(part);
        if (emojiMatch) {
          const emojiUrl = this.resolveFaceUrl(emojiMatch[1], emojiMatch[2]);
          if (emojiUrl) {
            spans.push({ type: 'image', imageSrc: emojiUrl });
          } else {
            spans.push({ type: 'text', text: part });
          }
          continue;
        }

        if (lowerPart.startsWith('[mobcent_phiz=')) {
          const phizUrl = part.substring(14, part.length - 1);
          spans.push({ type: 'image', imageSrc: phizUrl });
          continue;
        }

        if (lowerPart === '[b]') {
          boldCount++;
        } else if (lowerPart === '[/b]') {
          boldCount = Math.max(0, boldCount - 1);
        } else if (lowerPart === '[i]') {
          italicCount++;
        } else if (lowerPart === '[/i]') {
          italicCount = Math.max(0, italicCount - 1);
        } else if (lowerPart === '[u]') {
          underlineCount++;
        } else if (lowerPart === '[/u]') {
          underlineCount = Math.max(0, underlineCount - 1);
        } else if (lowerPart.startsWith('[color=')) {
          colorStack.push(part.substring(7, part.length - 1));
        } else if (lowerPart === '[/color]') {
          colorStack.pop();
        } else if (lowerPart.startsWith('[url')) {
          if (lowerPart.includes('=')) {
            urlStack.push(part.substring(part.indexOf('=') + 1, part.length - 1));
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
          isUnderline: underlineCount > 0,
          fontColor: colorStack.length > 0 ? colorStack[colorStack.length - 1] : undefined,
          url: finalUrl
        });
      }
    }
    return spans;
  }

  private parseMarkdownInlineSpans(text: string): InlineSpan[] {
    const spans: InlineSpan[] = [];
    if (!text) {
      return spans;
    }

    const tokenRegex = /(\[mobcent_phiz=[^\]]+\]|\[[a-zA-Z0-9_]+:\d+\]|<u>[^<]+<\/u>|~~[^~]+~~|\*\*[^*]+\*\*|\*[^*]+\*|\[[^\]]+\]\([^)]+\))/g;
    const tokenCheck = /(\[mobcent_phiz=[^\]]+\]|\[[a-zA-Z0-9_]+:\d+\]|<u>[^<]+<\/u>|~~[^~]+~~|\*\*[^*]+\*\*|\*[^*]+\*|\[[^\]]+\]\([^)]+\))/;
    const parts = text.split(tokenRegex);

    for (const part of parts) {
      if (!part) {
        continue;
      }

      if (tokenCheck.test(part)) {
        if (part.startsWith('[mobcent_phiz=')) {
          const phizUrl = part.substring(14, part.length - 1);
          spans.push({ type: 'image', imageSrc: phizUrl });
          continue;
        }

        const emojiMatch = /^\[([a-zA-Z0-9_]+):(\d+)\]$/.exec(part);
        if (emojiMatch) {
          const emojiUrl = this.resolveFaceUrl(emojiMatch[1], emojiMatch[2]);
          if (emojiUrl) {
            spans.push({ type: 'image', imageSrc: emojiUrl });
          } else {
            spans.push({ type: 'text', text: part });
          }
          continue;
        }

        const linkMatch = /^\[([^\]]+)\]\(([^)]+)\)$/.exec(part);
        if (linkMatch) {
          spans.push({
            type: 'text',
            text: linkMatch[1],
            url: linkMatch[2]
          });
          continue;
        }

        if (part.startsWith('**') && part.endsWith('**')) {
          spans.push({ type: 'text', text: part.substring(2, part.length - 2), isBold: true });
          continue;
        }

        if (part.startsWith('*') && part.endsWith('*')) {
          spans.push({ type: 'text', text: part.substring(1, part.length - 1), isItalic: true });
          continue;
        }

        if (part.startsWith('~~') && part.endsWith('~~')) {
          spans.push({ type: 'text', text: part.substring(2, part.length - 2), isStrikethrough: true });
          continue;
        }

        if (part.startsWith('<u>') && part.endsWith('</u>')) {
          spans.push({ type: 'text', text: part.substring(3, part.length - 4), isUnderline: true });
          continue;
        }
      }

      spans.push({ type: 'text', text: part });
    }

    return spans;
  }

  private normalizeImageUrl(url: string): string {
    const trimmed = url.trim();
    if (!trimmed) {
      return '';
    }
    return UrlUtil.buildUrl(this.baseUrl, trimmed);
  }

  private buildAttachmentUrl(aid: string): string {
    return UrlUtil.buildUrl(this.baseUrl, `/forum.php?mod=attachment&aid=${aid}`);
  }

  private getHeadingFontSize(level: number): number {
    if (level <= 1) {
      return this.textSize * 1.6;
    }
    if (level === 2) {
      return this.textSize * 1.4;
    }
    if (level === 3) {
      return this.textSize * 1.2;
    }
    return this.textSize * 1.1;
  }

  build() {
    Column() {
      Column({ space: CommonConstant.NormalContainerInnerPadding }) {
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

          } else if (item.type === 'divider') {
            Divider()
              .strokeWidth(CommonConstant.BorderSizeLarge)
              .color($r('sys.color.font_tertiary'))
              .opacity(0.4)

          } else if (item.type === 'heading') {
            Text(item.content)
              .fontSize(this.getHeadingFontSize(item.headingLevel || 1))
              .fontWeight(FontWeight.Bold)
              .fontColor(this.textColor)
              .width(CommonConstant.FullPercent)

          } else if (item.type === 'code') {
            Text(item.content)
              .fontSize(this.textSize * 0.95)
              .fontFamily('monospace')
              .fontColor(this.textColor)
              .width(CommonConstant.FullPercent)
              .backgroundColor($r('app.color.second_window_background'))
              .padding(CommonConstant.NormalContainerInnerPadding)
              .borderRadius(CommonConstant.RadiusSmall)
              .wordBreak(WordBreak.BREAK_ALL)

          } else if (item.type === 'task') {
            Row({ space: CommonConstant.SmallContainerInnerPadding }) {
              Text(item.taskChecked ? '[x]' : '[ ]')
                .fontSize(this.textSize)
                .fontColor(this.textColor)

              Text() {
                ForEach(item.spans || [], (span: InlineSpan) => {
                  if (span.type === 'image' && span.imageSrc) {
                    ImageSpan(span.imageSrc)
                      .width(this.textSize * 1.5)
                      .height(this.textSize * 1.5)
                      .objectFit(ImageFit.Contain)
                      .verticalAlign(ImageSpanAlignment.CENTER)
                  } else {
                    Span(span.text)
                      .fontSize(this.textSize)
                      .fontColor(span.url ? this.hyperlinkTextColor : (span.fontColor || this.textColor))
                      .fontWeight(span.isBold ? FontWeight.Bold : FontWeight.Normal)
                      .fontStyle(span.isItalic ? FontStyle.Italic : FontStyle.Normal)
                      .decoration({
                        type: span.url
                          ? TextDecorationType.Underline
                          : (span.isStrikethrough
                            ? TextDecorationType.LineThrough
                            : (span.isUnderline ? TextDecorationType.Underline : TextDecorationType.None)),
                        color: span.url ? this.hyperlinkTextColor : undefined,
                        style: span.url ? TextDecorationStyle.DASHED : undefined
                      })
                      .onClick(() => {
                        if (span.url) {
                          console.info('Link clicked:', span.url);
                        }
                      })
                  }
                })
              }
              .width(CommonConstant.FullPercent)
              .wordBreak(WordBreak.BREAK_ALL)
            }
            .width(CommonConstant.FullPercent)

          } else if (item.type === 'list') {
            Row({ space: CommonConstant.SmallContainerInnerPadding }) {
              Text(item.listOrdered ? `${item.listIndex || 1}.` : '•')
                .fontSize(this.textSize)
                .fontColor(this.textColor)
                .width(this.textSize * 2)
                .textAlign(TextAlign.End)

              Text() {
                ForEach(item.spans || [], (span: InlineSpan) => {
                  if (span.type === 'image' && span.imageSrc) {
                    ImageSpan(span.imageSrc)
                      .width(this.textSize * 1.5)
                      .height(this.textSize * 1.5)
                      .objectFit(ImageFit.Contain)
                      .verticalAlign(ImageSpanAlignment.CENTER)
                  } else {
                    Span(span.text)
                      .fontSize(this.textSize)
                      .fontColor(span.url ? this.hyperlinkTextColor : (span.fontColor || this.textColor))
                      .fontWeight(span.isBold ? FontWeight.Bold : FontWeight.Normal)
                      .fontStyle(span.isItalic ? FontStyle.Italic : FontStyle.Normal)
                      .decoration({
                        type: span.url
                          ? TextDecorationType.Underline
                          : (span.isStrikethrough
                            ? TextDecorationType.LineThrough
                            : (span.isUnderline ? TextDecorationType.Underline : TextDecorationType.None)),
                        color: span.url ? this.hyperlinkTextColor : undefined,
                        style: span.url ? TextDecorationStyle.DASHED : undefined
                      })
                      .onClick(() => {
                        if (span.url) {
                          console.info('Link clicked:', span.url);
                        }
                      })
                  }
                })
              }
              .width(CommonConstant.FullPercent)
              .wordBreak(WordBreak.BREAK_ALL)
            }
            .width(CommonConstant.FullPercent)

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
                  Span(span.text)
                    .fontSize(this.textSize)
                    .fontColor(span.url ? this.hyperlinkTextColor : (span.fontColor || this.textColor))
                    .fontWeight(span.isBold ? FontWeight.Bold : FontWeight.Normal)
                    .fontStyle(span.isItalic ? FontStyle.Italic : FontStyle.Normal)
                    .decoration({
                      type: span.url
                        ? TextDecorationType.Underline
                        : (span.isStrikethrough
                          ? TextDecorationType.LineThrough
                          : (span.isUnderline ? TextDecorationType.Underline : TextDecorationType.None)),
                      color: span.url ? this.hyperlinkTextColor : undefined,
                      style: span.url ? TextDecorationStyle.DASHED : undefined
                    })
                    .onClick(() => {
                      if (span.url) {
                        console.info('Link clicked:', span.url);
                      }
                    })
                }
              })
            }
            .width(CommonConstant.FullPercent)
            .wordBreak(WordBreak.BREAK_ALL)
            .copyOption(CopyOptions.LocalDevice)
            .lineHeight(CommonConstant.TextSizeUltraLarge)
          }
        })
      }
      .width(CommonConstant.FullPercent)
      .alignItems(HorizontalAlign.Start)
    }
    .width(CommonConstant.FullPercent)
    .alignItems(HorizontalAlign.Start)
  }
}
