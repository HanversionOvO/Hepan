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
  @Param useParallel: boolean = true;

  aboutToAppear(): void {
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

  build() {
    Column() {
      if (this.useParallel) {
        Markdown({
          text: this.content,
          controller: this.controller
        })
          .width(CommonConstant.FullPercent)
      } else {
        Text(this.content)
          .fontSize(this.textSize)
          .fontColor(this.textColor)
          .width(CommonConstant.FullPercent)
          .wordBreak(WordBreak.BREAK_ALL)
      }
    }
    .padding(CommonConstant.NormalContainerInnerPadding)
    .width(CommonConstant.FullPercent)
    .alignItems(HorizontalAlign.Start)
  }
}