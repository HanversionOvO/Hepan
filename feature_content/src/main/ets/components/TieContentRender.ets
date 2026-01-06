import { CommonConstant } from 'base_common';
import { CustomMarkdown } from 'base_ui';

export interface ContentItem {
  type: number;
  infor: string;
  url?: string;
  desc?: string;
  originalInfo?: string;
  aid?: number;
}

@ComponentV2
export struct TieContentRender {
  @Param @Require contents: ContentItem[];
  @Param textSize: number = CommonConstant.TextSizeNormal;
  @Local displayItems: ContentItem[] = [];
  @Local attachmentItems: ContentItem[] = [];

  aboutToAppear() {
    this.processContents();
  }

  @Monitor('contents')
  onContentsChange() {
    this.processContents();
  }

  private processContents() {
    if (!this.contents) {
      this.displayItems = [];
      this.attachmentItems = [];
      return;
    }
    this.displayItems = this.contents.filter(item => item.type !== 5);
    this.attachmentItems = this.contents.filter(item => item.type === 5);
  }

  @Builder
  AttachmentCard(item: ContentItem) {
    Row() {
      Image($r('sys.media.ohos_app_icon'))
        .width(40)
        .height(40)
        .objectFit(ImageFit.Contain)
        .margin({ right: CommonConstant.NormalContainerInnerPadding })

      Column({ space: 4 }) {
        Text(item.infor)
          .fontSize(CommonConstant.TextSizeNormal)
          .fontColor($r('sys.color.font_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(item.desc || '未知大小')
          .fontSize(CommonConstant.TextSizeSmall)
          .fontColor($r('sys.color.font_tertiary'))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Button('下载')
        .fontSize(CommonConstant.TextSizeSmall)
        .height(28)
        .backgroundColor(CommonConstant.ThemeColor)
        .onClick(() => {
          if (item.url) {
            console.info('Download requested:', item.url);
          }
        })
    }
    .width(CommonConstant.FullPercent)
    .padding(CommonConstant.NormalContainerInnerPadding)
    .backgroundColor($r('app.color.tetertiary_window_background'))
    .borderRadius(CommonConstant.RadiusNormal)
    .margin({ top: CommonConstant.SmallContainerInnerPadding })
  }

  build() {
    Column({ space: CommonConstant.NormalContainerInnerPadding }) {
      ForEach(this.displayItems, (item: ContentItem, index: number) => {
        if (item.type === 0) {
          // 文本（自动处理行内链接样式）
          CustomMarkdown({
            content: item.infor,
            useParallel: false,
            textSize: this.textSize
          })
        } else if (item.type === 1) {
          // 图片
          Image(item.originalInfo || item.infor)
            .width(CommonConstant.FullPercent)
            .objectFit(ImageFit.Contain)
            .borderRadius(CommonConstant.RadiusNormal)
            .backgroundColor($r('app.color.tetertiary_window_background'))
            .enableAnalyzer(true)

        } else if (item.type === 4) {
          // --- 核心修改：Type 4 链接改为文本样式展示 ---
          // "链接应该是在原文本中的" -> 移除卡片背景，使用文本链接样式
          Text(item.infor)
            .fontSize(this.textSize)
            .fontColor(CommonConstant.ThemeColor)
            .decoration({
              type: TextDecorationType.Underline,
              color: CommonConstant.ThemeColor,
              style: TextDecorationStyle.DASHED
            })
            .onClick(() => {
              const targetUrl = item.url || item.infor;
              console.info('Open link:', targetUrl);
            })
            // 稍微增加一点点击区域，但不像卡片那么大
            .padding({ top: 4, bottom: 4 })

        } else if (item.type === 3) {
          // 音频
          Row() {
            Text("🎵 音频内容").fontColor($r('sys.color.font_secondary'))
          }
          .width(CommonConstant.FullPercent)
          .padding(10)
          .backgroundColor($r('app.color.tetertiary_window_background'))
        }
      })

      if (this.attachmentItems.length > 0) {
        Column() {
          Divider()
            .margin({ top: 10, bottom: 10 })
            .color($r('sys.color.font_tertiary'))
            .opacity(0.5)

          Text("附件列表")
            .fontSize(CommonConstant.TextSizeSmall)
            .fontColor($r('sys.color.font_secondary'))
            .width(CommonConstant.FullPercent)
            .margin({ bottom: 5 })

          ForEach(this.attachmentItems, (item: ContentItem) => {
            this.AttachmentCard(item)
          })
        }
        .width(CommonConstant.FullPercent)
      }
    }
    .width(CommonConstant.FullPercent)
    .alignItems(HorizontalAlign.Start)
  }
}