import { Markdown, MarkdownController } from '@luvi/lv-markdown-in';
import { CommonConstant } from 'base_common';

@ComponentV2
export struct CustomMarkdown {
  @Param @Require content: string;
  @Param controller: MarkdownController = new MarkdownController();
  @Param titleColor: ResourceColor = $r('sys.color.font_primary');
  @Param textColor: ResourceColor = $r('sys.color.font_primary');
  @Param textSize: number = CommonConstant.TextSizeNormal;
  @Param quoteBorderColor: ResourceColor = CommonConstant.ThemeColor;
  @Param quoteTextColor: ResourceColor = $r('sys.color.font_primary');
  @Param quoteBgColor: ResourceColor = $r('app.color.tetertiary_window_background');
  @Param hyperlinkTextColor: ResourceColor = CommonConstant.ThemeColor;

  aboutToAppear(): void {
    this.controller
      .setTitleColor(this.titleColor)
      .setTextColor(this.textColor)
      .setTextSize(this.textSize)
      .setQuoteBorderColor(this.quoteBorderColor)
      .setQuoteBackgroundColor(this.quoteBgColor)
      .setHyperlinkTextColor(this.hyperlinkTextColor)
  }

  build() {
    // 可以在这里统一处理 Markdown 的容器样式，例如内边距、背景色等
    Column() {
      Markdown({
        text: this.content,
        controller: this.controller
      })
    }
    .width(CommonConstant.FullPercent)
    .alignItems(HorizontalAlign.Start)
  }
}