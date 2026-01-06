import { ResUtil } from '@pura/harmony-utils';
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
  // 接收引用内容和用户名
  @Param quoteContent: string = '';
  @Param quoteUserName: string = '';
  @Param isQuote: number = 0;
  @Local displayItems: ContentItem[] = [];
  @Local attachmentItems: ContentItem[] = [];

  aboutToAppear() {
    this.processContents();
  }

  @Monitor('contents', 'quoteContent', 'quoteUserName', 'isQuote')
  onContentsChange() {
    this.processContents();
  }

  private processContents() {
    if (!this.contents) {
      this.displayItems = [];
      this.attachmentItems = [];
      return;
    }

    let tempItems: ContentItem[] = [];

    if (this.isQuote === 1 && this.quoteContent && this.quoteContent.trim().length > 0) { // [!code ++] 修改判断逻辑
      tempItems.push({
        type: 6,
        infor: this.quoteContent,
        originalInfo: this.quoteUserName
      });
    }

    this.contents.forEach(item => {
      if (item.type === 5) {
        return;
      }
      tempItems.push({
        type: item.type,
        infor: item.infor,
        url: item.url,
        desc: item.desc,
        originalInfo: item.originalInfo,
        aid: item.aid
      });
    });

    this.displayItems = tempItems;
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

        } else if (item.type === 6) {
          // 引用/回复卡片渲染
          Column({ space: CommonConstant.SmallContainerInnerPadding }) {
            if (item.originalInfo && item.originalInfo.trim().length > 0) {
              Row() {
                Text(ResUtil.getStringSync($r('app.string.TieContentPage_reply')) + " ")
                  .fontSize(CommonConstant.TextSizeSmall)
                  .fontColor($r('sys.color.font_tertiary'))
                Text(item.originalInfo)
                  .fontSize(CommonConstant.TextSizeSmall)
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Bold)
                Text(": ")
                  .fontSize(CommonConstant.TextSizeSmall)
                  .fontColor($r('sys.color.font_tertiary'))
              }
              .width(CommonConstant.FullPercent)
            }

            // 引用内容始终显示
            Text(item.infor)
              .fontSize(CommonConstant.TextSizeNormal)
              .fontColor($r('sys.color.font_secondary'))
              .maxLines(4)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width(CommonConstant.FullPercent)
          .padding(CommonConstant.NormalContainerInnerPadding)
          .backgroundColor($r('app.color.second_window_background'))
          .borderRadius(CommonConstant.RadiusNormal)
          .alignItems(HorizontalAlign.Start)
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