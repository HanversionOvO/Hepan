import { AppUtil, ResUtil } from '@pura/harmony-utils';
import { util } from '@kit.ArkTS';
import resourceManager from '@ohos.resourceManager';
import { AppPreferenceKeys, CommonConstant, PreferenceUtil, SummaryAttachments, UrlUtil } from 'base_common';
import { CustomMarkdown, GlassButton } from 'base_ui';

interface FaceItem {
  icon_url: string;
  icon_type: string;
  icon_index: number;
}

interface FaceCollection {
  base_url: string;
  collections: FaceItem[];
}

@ComponentV2
export struct TieContentRender {
  @Param @Require message: string;
  @Param format: number = 0;
  @Param attachments: SummaryAttachments[] = [];
  @Param textSize: number = CommonConstant.TextSizeNormal;
  @Local displayMessage: string = '';
  @Local attachmentItems: SummaryAttachments[] = [];
  @Local baseUrl: string = CommonConstant.BASE_URL;
  @Local isMarkdown: boolean = false;
  private faceUrlMap: Map<string, string> = new Map();
  private faceLoaded: boolean = false;

  aboutToAppear() {
    this.loadBaseUrl();
    this.loadFaceData();
    this.processMessage();
  }

  @Monitor('message', 'format', 'attachments')
  onContentsChange() {
    this.processMessage();
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
          const fullUrl = UrlUtil.buildUrl(this.baseUrl, relativePath);
          this.faceUrlMap.set(key, fullUrl);
        });
      });
      this.faceLoaded = true;
      this.processMessage();
    } catch (error) {
      this.faceLoaded = true;
    }
  }

  private processMessage() {
    const rawMessage = this.message || '';
    const attachments = this.attachments || [];
    const attachmentMap: Map<number, SummaryAttachments> = new Map();
    const attachmentItems: SummaryAttachments[] = [];
    const attachmentSet: Set<number> = new Set();

    attachments.forEach((attachment) => {
      attachmentMap.set(attachment.attachment_id, attachment);
      if (attachment.is_image !== 1) {
        this.appendAttachment(attachment, attachmentItems, attachmentSet);
      }
    });

    this.isMarkdown = this.format === 2;
    let processed = rawMessage;

    if (attachmentMap.size > 0) {
      processed = this.isMarkdown
        ? this.processMarkdownMessage(processed, attachmentMap, attachmentItems, attachmentSet)
        : this.processBbCodeMessage(processed, attachmentMap, attachmentItems, attachmentSet);
    }

    if (this.faceLoaded) {
      processed = this.replaceEmojiTokens(processed);
    }

    this.displayMessage = processed.trim();
    this.attachmentItems = attachmentItems;
  }

  private processMarkdownMessage(message: string, attachmentMap: Map<number, SummaryAttachments>,
    attachmentItems: SummaryAttachments[], attachmentSet: Set<number>): string {
    return message.replace(/\((a|i):(\d+)\)/g, (match: string, type: string, id: string) => {
      const attachmentId = Number(id);
      const attachment = attachmentMap.get(attachmentId);
      if (!attachment) {
        return match;
      }
      if (attachment.is_image === 1) {
        const imageUrl = this.buildAttachmentImageUrl(attachment);
        return imageUrl ? `(${imageUrl})` : match;
      }
      if (type === 'a') {
        this.appendAttachment(attachment, attachmentItems, attachmentSet);
        const downloadUrl = this.buildAttachmentDownloadUrl(attachment);
        return downloadUrl ? `(${downloadUrl})` : match;
      }
      return match;
    });
  }

  private processBbCodeMessage(message: string, attachmentMap: Map<number, SummaryAttachments>,
    attachmentItems: SummaryAttachments[], attachmentSet: Set<number>): string {
    return message.replace(/\[attach\](\d+)\[\/attach\]/g, (match: string, id: string) => {
      const attachmentId = Number(id);
      const attachment = attachmentMap.get(attachmentId);
      if (!attachment) {
        return '';
      }
      if (attachment.is_image === 1) {
        const imageUrl = this.buildAttachmentImageUrl(attachment);
        return imageUrl ? `[img]${imageUrl}[/img]` : '';
      }
      this.appendAttachment(attachment, attachmentItems, attachmentSet);
      return '';
    });
  }

  private replaceEmojiTokens(message: string): string {
    if (this.isMarkdown) {
      return message;
    }
    return message.replace(/\[([a-zA-Z0-9_]+):(\d+)\]/g, (match: string, iconType: string, index: string) => {
      const faceUrl = this.resolveFaceUrl(iconType, index);
      return faceUrl ? `[mobcent_phiz=${faceUrl}]` : match;
    });
  }

  private resolveFaceUrl(iconType: string, iconIndex: string): string {
    const indexValue = Number(iconIndex);
    if (!Number.isFinite(indexValue)) {
      return '';
    }
    const key = `${iconType}:${indexValue}`;
    const direct = this.faceUrlMap.get(key);
    if (direct) {
      return direct;
    }
    if (iconType !== 'a') {
      return this.faceUrlMap.get(`a:${indexValue}`) || '';
    }
    return '';
  }

  private appendAttachment(attachment: SummaryAttachments, list: SummaryAttachments[], tracker: Set<number>) {
    if (!tracker.has(attachment.attachment_id)) {
      tracker.add(attachment.attachment_id);
      list.push(attachment);
    }
  }

  private buildAttachmentImageUrl(attachment: SummaryAttachments): string {
    const path = attachment.thumbnail_url || attachment.raw_url || attachment.download_url || attachment.path;
    if (!path) {
      return '';
    }
    return UrlUtil.buildUrl(this.baseUrl, path);
  }

  private buildAttachmentDownloadUrl(attachment: SummaryAttachments): string {
    const path = attachment.download_url || attachment.raw_url || attachment.path;
    if (!path) {
      return '';
    }
    return UrlUtil.buildUrl(this.baseUrl, path);
  }

  private formatFileSize(size: number): string {
    if (!size || size <= 0) {
      return ResUtil.getStringSync($r('app.string.TieContentPage_unknown_size'));
    }
    const kb = size / 1024;
    if (kb < 1024) {
      return `${kb.toFixed(1)} KB`;
    }
    const mb = kb / 1024;
    return `${mb.toFixed(1)} MB`;
  }

  @Builder
  AttachmentCard(item: SummaryAttachments) {
    Row() {
      Image($r('app.media.file_icon'))
        .width(CommonConstant.IconSizeLarge)
        .height(CommonConstant.IconSizeLarge)
        .objectFit(ImageFit.Contain)
        .margin({ right: CommonConstant.NormalContainerInnerPadding })

      Column({ space: CommonConstant.SmallContainerInnerPadding }) {
        Text(item.filename || '')
          .fontSize(CommonConstant.TextSizeNormal)
          .fontColor($r('sys.color.font_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.formatFileSize(item.size))
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
          const url = this.buildAttachmentDownloadUrl(item);
          if (url) {
            // TODO: download attachment by url
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
      if (this.displayMessage.length > 0) {
        CustomMarkdown({
          content: this.displayMessage,
          useMarkDown: this.isMarkdown,
          textSize: this.textSize
        })
      }

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

          ForEach(this.attachmentItems, (item: SummaryAttachments) => {
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
