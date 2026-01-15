import { LogUtil } from '@pura/harmony-utils';
import { AttachmentApi, AtUser, BaseVM, ForumApi, ReplyRequest, ToastUtil, UploadedFile } from 'base_common';
import { picker } from '@kit.CoreFileKit';
import { IImagePickerVM, PostImageModel } from 'feature_post'; // 从 feature_post 导入
import { inputMethod } from '@kit.IMEKit';
import { PickerUtil } from '@pura/picker_utils';

const TAG = '[ReplyPageVM]: ';
const BASE_URL = 'https://bbs.uestc.edu.cn';

@ObservedV2
export class ReplyPageVM extends BaseVM implements IImagePickerVM {
  @Trace threadId: number = 0;
  @Trace postId: number = 0;
  @Trace replyUser: string = '';
  @Trace replyDate: string = '';
  @Trace quoteContent: string = '';
  @Trace replyContent: string = '';
  @Trace isAnonymous: boolean = false;
  @Trace usesig: boolean = true;
  @Trace uploadedImages: PostImageModel[] = [];
  @Trace isShowFace: boolean = false;
  @Trace isShowAt: boolean = false;
  @Trace isInsertImageMode: boolean = false;
  @Trace isInputting: boolean = false;
  @Trace selectionStart: number = 0;
  @Trace selectionEnd: number = 0;
  @Trace isSendSuccess: boolean = false;
  controller: TextAreaController = new TextAreaController();

  init(threadId: number, postId: number = 0, replyUser: string = '', replyDate: string = '',
    quoteContent: string = '') {
    this.threadId = threadId;
    this.postId = postId;
    this.replyUser = replyUser;
    this.replyDate = replyDate;
    this.quoteContent = quoteContent;
  }

  // === 实现 IImagePickerVM 接口 ===
  async selectImage() {
    const maxCount = 9 - this.uploadedImages.length;
    if (maxCount <= 0) {
      ToastUtil.showError($r('app.string.PostPage_select_photo_error')); // 复用 PostPage 字符串或定义新的
      return;
    }

    try {
      const uris = await PickerUtil.selectPhoto({
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: maxCount
      });

      if (uris && uris.length > 0) {
        uris.forEach((uri: string) => {
          const imgModel = new PostImageModel(uri);
          this.uploadedImages.push(imgModel);
          this.uploadImage(imgModel);
        });
      }
    } catch (e) {
      LogUtil.error(TAG, 'Select photo failed:', e);
    }
  }

  async uploadImage(img: PostImageModel) {
    try {
      const uploadedFile = await AttachmentApi.uploadImage(img.localUri);
      img.attachment = uploadedFile;
      let displayUrl = uploadedFile.raw_url || uploadedFile.thumbnail_url || uploadedFile.path;
      if (displayUrl && !displayUrl.startsWith('http')) {
        displayUrl = BASE_URL + displayUrl;
      }
      img.remoteUrl = displayUrl || '';
      img.isLoading = false;
    } catch (e) {
      LogUtil.error(TAG, 'Upload failed:', e);
      ToastUtil.showError('上传失败');
      const index = this.uploadedImages.indexOf(img);
      if (index !== -1) {
        this.uploadedImages.splice(index, 1);
      }
    }
  }

  deleteImage(index: number) {
    if (index >= 0 && index < this.uploadedImages.length) {
      this.uploadedImages.splice(index, 1);
    }
  }

  insertImageToContent(img: PostImageModel) {
    if (img.isLoading) {
      ToastUtil.showInfo('图片正在上传中');
      return;
    }
    if (!img.remoteUrl) {
      ToastUtil.showError('图片上传失败，无法插入');
      return;
    }
    this.insertImage(img.remoteUrl);
    this.isInsertImageMode = false;
  }

  updateContentSelection(start: number, end: number) {
    this.selectionStart = start;
    this.selectionEnd = end;
  }

  private insertText(text: string) {
    const start = this.selectionStart;
    const end = this.selectionEnd;
    const currentText = this.replyContent;
    const newText = currentText.substring(0, start) + text + currentText.substring(end);
    this.replyContent = newText;

    // 移动光标
    setTimeout(() => {
      const newCursor = start + text.length;
      this.selectionStart = newCursor;
      this.selectionEnd = newCursor;
      this.controller.caretPosition(newCursor);
    }, 50);
  }

  insertImage(url: string) {
    const text = `![image](${url})`;
    this.insertText(text);
  }

  insertFace(faceText: string) {
    this.insertText(faceText);
  }

  insertAtUser(user: AtUser) {
    const text = `[@${user.username}](at:${user.uid}) `;
    this.insertText(text);
  }

  closeKeyboard() {
    try {
      inputMethod.getController().stopInputSession();
    } catch (error) {
      LogUtil.error(TAG, 'Stop input session failed:', error);
    }
  }

  async sendReply(): Promise<boolean> {
    if (!this.replyContent.trim()) {
      ToastUtil.showLightWarn($r('app.string.ReplyPage_please_input'));
      return false;
    }

    ToastUtil.showLoading($r('app.string.ReplyPage_sending'));

    // 构建附件和内容
    const attachments: UploadedFile[] = [];
    let processedMessage = this.replyContent;

    this.uploadedImages.forEach(img => {
      if (img.attachment) {
        attachments.push(img.attachment);
        if (img.remoteUrl) {
          const escapedUrl = img.remoteUrl.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
          const regex = new RegExp(`\\!\\[.*?\\]\\(${escapedUrl}\\)`, 'g');
          if (processedMessage.match(regex)) {
            processedMessage =
              processedMessage.replace(regex, `![${img.attachment.filename}](i:${img.attachment.attachment_id})`);
          } else {
            processedMessage += `\n\n![${img.attachment.filename}](i:${img.attachment.attachment_id})`;
          }
        }
      }
    });

    if (this.postId > 0) {
      const quoteHeader =
        `> ${this.replyUser} 发表于 [${this.replyDate}](/goto/${this.postId})\n> ${this.quoteContent}\n\n`;
      processedMessage = quoteHeader + processedMessage;
    }

    const request: ReplyRequest = {
      thread_id: this.threadId,
      message: processedMessage,
      usesig: this.usesig ? 1 : 0,
      is_anonymous: this.isAnonymous,
      attachments: attachments,
      format: 2,
      post_id: this.postId > 0 ? this.postId : undefined
    };

    try {
      await ForumApi.reply(request);
      ToastUtil.hideLoading();
      ToastUtil.showLightSuccess($r('app.string.ReplyPage_reply_success'));
      this.isSendSuccess = true;
      return true;
    } catch (e) {
      ToastUtil.hideLoading();
      LogUtil.error(TAG, `Reply failed: ${e}`);
      ToastUtil.showError(e.message || '回复失败');
      return false;
    }
  }
}
