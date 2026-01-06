import { CommonConstant } from 'base_common';
import { CustomMarkdown, GlassButton } from 'base_ui';

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
      Image($r('app.media.file_icon'))
        .width(CommonConstant.IconSizeLarge)
        .height(CommonConstant.IconSizeLarge)
        .objectFit(ImageFit.Contain)
        .margin({ right: CommonConstant.NormalContainerInnerPadding })

      Column({ space: CommonConstant.SmallContainerInnerPadding }) {
        Text(item.infor)
          .fontSize(CommonConstant.TextSizeNormal)
          .fontColor($r('sys.color.font_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(item.desc || $r('app.string.TieContentPage_unknown_size'))
          .fontSize(CommonConstant.TextSizeSmall)
          .fontColor($r('sys.color.font_tertiary'))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      GlassButton({
        text: $r('app.string.TieContentPage_download'),
        innerFontSize: CommonConstant.TextSizeSmall
      })
        .onClick(() => {
          if (item.url) {
            // TODO: 下载附件逻辑
          }
        })
    }
    .width(CommonConstant.FullPercent)
    .padding(CommonConstant.NormalContainerInnerPadding)
    .backgroundColor($r('app.color.second_window_background'))
    .borderRadius(CommonConstant.RadiusNormal)
    .margin({ top: CommonConstant.SmallContainerInnerPadding })
  }

  build() {
    Column({ space: CommonConstant.NormalContainerInnerPadding }) {
      ForEach(this.displayItems, (item: ContentItem, index: number) => {
        if (item.type === 0) {
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
            .backgroundColor($r('app.color.second_window_background'))
            .enableAnalyzer(true)

        } else if (item.type === 4) {
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
              // TODO: 链接点击
            })
            .padding({
              top: CommonConstant.SmallContainerInnerPadding,
              bottom: CommonConstant.SmallContainerInnerPadding
            })

        } else if (item.type === 3) {
          // 音频
          Row() {
            Text($r('app.string.TieContentPage_music')).fontColor($r('sys.color.font_secondary'))
          }
          .width(CommonConstant.FullPercent)
          .padding(CommonConstant.NormalContainerInnerPadding)
          .backgroundColor($r('app.color.second_window_background'))
        }
      })

      if (this.attachmentItems.length > 0) {
        Column({ space: CommonConstant.NormalContainerInnerPadding }) {
          Divider()
            .margin({
              top: CommonConstant.NormalContainerInnerPadding,
            })
            .color($r('sys.color.font_tertiary'))
            .opacity(0.3)

          Text($r('app.string.TieContentPage_attachment_list'))
            .fontSize(CommonConstant.TextSizeSmall)
            .fontColor($r('sys.color.font_secondary'))
            .width(CommonConstant.FullPercent)

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