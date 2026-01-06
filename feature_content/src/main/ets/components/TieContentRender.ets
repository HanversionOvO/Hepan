import { CommonConstant } from 'base_common';
import { CustomMarkdown } from 'base_ui';

// 定义内容接口，参考 API 返回结构
export interface ContentItem {
  type: number; // 0:文本, 1:图片, 3:音频, 4:链接, 5:附件
  infor: string; // 核心内容或文件名
  url?: string; // 链接或下载地址
  desc?: string; // 附件大小描述等
  originalInfo?: string; // 图片原图地址
  aid?: number; // 附件ID
}

@ComponentV2
export struct TieContentRender {
  @Param @Require contents: ContentItem[];
  @Param textSize: number = CommonConstant.TextSizeNormal;
  // 计算属性：分离普通内容和附件
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
    // Type 5 为附件，放置于末尾；其他按顺序展示
    this.displayItems = this.contents.filter(item => item.type !== 5);
    this.attachmentItems = this.contents.filter(item => item.type === 5);
  }

  @Builder
  AttachmentCard(item: ContentItem) {
    Row() {
      // 附件图标
      Image($r('sys.media.ohos_app_icon')) // 建议替换为专门的文件图标
        .width(40)
        .height(40)
        .objectFit(ImageFit.Contain)
        .margin({ right: CommonConstant.NormalContainerInnerPadding })

      Column({ space: 4 }) {
        Text(item.infor) // 文件名
          .fontSize(CommonConstant.TextSizeNormal)
          .fontColor($r('sys.color.font_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(item.desc || '未知大小') // 大小描述
          .fontSize(CommonConstant.TextSizeSmall)
          .fontColor($r('sys.color.font_tertiary'))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 下载按钮
      Button('下载')
        .fontSize(CommonConstant.TextSizeSmall)
        .height(28)
        .backgroundColor(CommonConstant.ThemeColor)
        .onClick(() => {
          if (item.url) {
            // TODO: 处理下载逻辑，item.url 即为下载链接
            console.info('Download:', item.url);
          }
        })
    }
    .width(CommonConstant.FullPercent)
    .padding(CommonConstant.NormalContainerInnerPadding)
    .backgroundColor($r('app.color.tetertiary_window_background'))
    .borderRadius(CommonConstant.RadiusNormal)
    .margin({ top: CommonConstant.SmallContainerInnerPadding })
  }

  @Builder
  LinkCard(item: ContentItem) {
    Row() {
      Text('🔗 链接：')
        .fontSize(this.textSize)
        .fontColor($r('sys.color.font_secondary'))
      Text(item.infor) // 链接文本
        .fontSize(this.textSize)
        .fontColor(CommonConstant.ThemeColor)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
    }
    .width(CommonConstant.FullPercent)
    .padding(CommonConstant.SmallContainerInnerPadding)
    .backgroundColor($r('app.color.tetertiary_window_background'))
    .borderRadius(CommonConstant.RadiusSmall)
    .onClick(() => {
      // TODO: 打开链接
      const targetUrl = item.url || item.infor;
      console.info('Open link:', targetUrl);
    })
  }

  build() {
    Column({ space: CommonConstant.NormalContainerInnerPadding }) {
      // 1. 渲染主体内容
      ForEach(this.displayItems, (item: ContentItem, index: number) => {
        if (item.type === 0) {
          // 文本：使用增强版 CustomMarkdown 解析 BBCode 和 phiz 表情
          CustomMarkdown({
            content: item.infor,
            useParallel: false, // 关键：关闭并行模式，使用手动解析
            textSize: this.textSize
          })
        } else if (item.type === 1) {
          // 图片
          Image(item.originalInfo || item.infor)
            .width(CommonConstant.FullPercent)
            .objectFit(ImageFit.Contain)
            .borderRadius(CommonConstant.RadiusNormal)
            .backgroundColor($r('app.color.tetertiary_window_background'))
            .enableAnalyzer(true) // 开启图片分析（如文字提取）

        } else if (item.type === 3) {
          // 音频 (占位)
          Row() {
            Text("🎵 音频内容: " + item.infor).fontColor($r('sys.color.font_secondary'))
          }.width(CommonConstant.FullPercent).padding(10).backgroundColor($r('app.color.tetertiary_window_background'))

        } else if (item.type === 4) {
          // 链接
          this.LinkCard(item)
        }
      })

      // 2. 渲染末尾附件
      if (this.attachmentItems.length > 0) {
        Column() {
          Divider().margin({ top: 10, bottom: 10 })
          Text("附件列表")
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