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
  @Local displayItems: ContentItem[] = [];
  @Local attachmentItems: ContentItem[] = [];

  aboutToAppear() {
    this.processContents();
  }

  @Monitor('contents','quoteContent','quoteUserName')
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

    // 1. 处理引用内容（放在最前面）
    // 只要有引用内容就显示，不再强依赖用户名或 is_quote 标记
    if (this.quoteContent && this.quoteContent.trim().length > 0) {
      tempItems.push({
        type: 6, // 自定义类型：引用块
        infor: this.quoteContent,
        originalInfo: this.quoteUserName
      });
    }

    // 2. 处理正文内容
    this.contents.forEach(item => {
      // 过滤附件
      if (item.type === 5) {
        return;
      }

      // 直接透传内容，不再进行正则拆分
      // mobcent_phiz 表情将交由 CustomMarkdown 的 ImageSpan 行内渲染
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
          // 纯文本：使用 CustomMarkdown 并关闭并行模式，以启用 parseInlineSpans 处理 mobcent_phiz
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
          // 链接
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
            // 只有当有用户名时，才显示“回复 xxx”的标题
            if (item.originalInfo && item.originalInfo.trim().length > 0) {
              Row() {
                Text("回复 ")
                  .fontSize(CommonConstant.TextSizeSmall)
                  .fontColor($r('sys.color.font_tertiary'))
                Text(item.originalInfo)
                  .fontSize(CommonConstant.TextSizeSmall)
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Bold)
                Text("：")
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