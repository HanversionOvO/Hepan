import { AppUtil, LogUtil } from '@pura/harmony-utils';
import {
  AttachmentApi,
  BaseVM,
  Chat,
  ChatSendContent,
  CommonConstant,
  MessageApi,
  RecentMessage,
  RouterUtil,
  StackEnum
} from 'base_common';
import { CustomFilePanelItem, ImageLongTakePreviewUtil } from 'base_ui';
import { PhotoHelper, PickerUtil } from '@pura/picker_utils';

const TAG = '[ChatPageVM]: ';

@ObservedV2
export class ChatPageVM extends BaseVM {
  @Trace isHideNavBar: boolean = false;
  @Trace isLoadingHistory: boolean = false;
  @Trace showNewMessageTip: boolean = false;
  @Trace isShowFacePanel: boolean = false;
  @Trace isShowFilePanel: boolean = false;
  @Trace chatScroller: Scroller = new Scroller();
  @Trace recentMessage: RecentMessage = new RecentMessage();
  @Trace richEditorController: RichEditorController = new RichEditorController();
  @Trace chats: Chat[] = [];
  @Trace isUserOnline: boolean = false;
  @Trace previewingImageMid: number = -1;
  @Trace stackName: StackEnum = StackEnum.MESSAGE;
  @Trace filePanelItems: CustomFilePanelItem[] = [
    {
      title: $r('app.string.ChatPage_take_photo'), icon: $r('sys.symbol.camera'), onClick: async () => {
      await this.takePhoto();
    }
    },
    {
      title: $r('app.string.ChatPage_select_image'), icon: $r('sys.symbol.picture'), onClick: async () => {
      await this.selectImage()
    }
    },
  ];
  isAtBottom: boolean = true;
  private timerId: number = -1;

  async startMessage() {
    await this.loadData();
    this.startListen();
  }

  async loadData() {
    if (this.recentMessage) {
      const chats: Chat[] = await MessageApi.getChat(this.recentMessage.toUserId, 0, 0, 10);
      this.isUserOnline = await MessageApi.queryOnline(this.recentMessage.toUserId);
      this.chats = chats.sort((a, b) => Number(a.time) - Number(b.time));
      this.isAtBottom = true;
      setTimeout(() => {
        this.chatScroller.scrollEdge(Edge.Bottom);
      }, 100);
    }
  }

  startListen() {
    this.stopListen();
    this.timerId = setInterval(() => {
      this.checkNewMessage();
    }, 3000);
  }

  stopListen() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  async checkNewMessage() {
    if (!this.recentMessage) {
      return;
    }

    try {
      const lastMsg = this.chats.length > 0 ? this.chats[this.chats.length - 1] : null;
      const startTime = lastMsg ? Number(lastMsg.time) : 0;

      const newChats = await MessageApi.getChat(this.recentMessage.toUserId, startTime, 0, 10);

      if (newChats && newChats.length > 0) {
        const existingMids = new Set(this.chats.map(c => c.mid));
        const validNewChats = newChats.filter(c => !existingMids.has(c.mid));

        if (validNewChats.length > 0) {
          LogUtil.debug(TAG, `Received ${validNewChats.length} new messages`);

          validNewChats.sort((a, b) => Number(a.time) - Number(b.time));
          this.chats.push(...validNewChats);

          if (this.isAtBottom) {
            setTimeout(() => {
              this.chatScroller.scrollEdge(Edge.Bottom);
            }, 100);
          } else {
            this.showNewMessageTip = true;
          }
        }
      }
    } catch (e) {
      LogUtil.error(TAG, 'Check new message failed: ' + JSON.stringify(e));
    }
  }

  updateBottomStatus(isAtBottom: boolean) {
    this.isAtBottom = isAtBottom;
    if (isAtBottom) {
      AppUtil.getUIContext()
        .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveNormal },
          () => {
            this.showNewMessageTip = false;
          })
    }
  }

  async loadHistory() {
    if (this.isLoadingHistory || this.chats.length === 0 || !this.recentMessage) {
      return;
    }

    this.isLoadingHistory = true;
    try {
      const oldestChat = this.chats[0];
      const stopTime = Number(oldestChat.time);

      const currentCacheCount = this.chats.length;

      const historyChats: Chat[] = await MessageApi.getChat(
        this.recentMessage.toUserId,
        0,
        stopTime,
        10,
        currentCacheCount
      );

      if (historyChats && historyChats.length > 0) {
        const existingMids = new Set(this.chats.map(c => c.mid));
        const newChats = historyChats.filter(c => !existingMids.has(c.mid));

        if (newChats.length > 0) {
          newChats.sort((a, b) => Number(a.time) - Number(b.time));
          this.chats = [...newChats, ...this.chats];
        }
      }
    } catch (e) {
      console.error(TAG, 'Load history failed: ', e);
    } finally {
      this.isLoadingHistory = false;
    }
  }

  async sendMessage(msg: ChatSendContent) {
    if (this.recentMessage) {
      try {
        await MessageApi.sendMessage(this.recentMessage.toUserId, msg, this.recentMessage.plid, this.recentMessage.pmid);
      } catch (e) {
        LogUtil.error(TAG, 'Send message failed: ' + JSON.stringify(e));
      }
    }
  }

  async uploadAndSendImage(uri: string) {
    if (!uri) {
      return;
    }

    try {
      // 调用 AttachmentApi 上传，现在返回的是 UploadedFile 对象
      const uploadedFile = await AttachmentApi.uploadImage(uri);

      if (uploadedFile) {
        const contentUrl = uploadedFile.raw_url || uploadedFile.thumbnail_url || uploadedFile.path;

        if (contentUrl) {
          await this.sendMessage({
            type: 'image',
            content: contentUrl
          });
          this.isShowFilePanel = false;
        }
      }
    } catch (e) {
      LogUtil.error(TAG, 'Send image failed: ' + JSON.stringify(e));
    }
  }

  async takePhoto() {
    try {
      const result: string = await PickerUtil.cameraEasy();

      if (result) {
        await this.uploadAndSendImage(result);
      }
    } catch (e) {
      LogUtil.error(TAG, 'Take photo failed: ' + JSON.stringify(e));
    }
  }

  async selectImage() {
    try {
      const results: string[] = await PhotoHelper.selectEasy({
        maxSelectNumber: 1
      });
      if (results && results.length > 0) {
        await this.uploadAndSendImage(results[0]);
      }
    } catch (e) {
      LogUtil.error(TAG, 'Select image failed: ' + JSON.stringify(e));
    }
  }

  getImageComponentId(chat: Chat): string {
    return `chat_image_${chat.mid || chat.time || 0}`;
  }

  showImagePreview(uiContext: UIContext, chat: Chat): void {
    if (!chat || chat.type !== 'image' || !chat.content) {
      return;
    }
    const componentId = this.getImageComponentId(chat);
    ImageLongTakePreviewUtil.show({
      uiContext: uiContext,
      componentId: componentId,
      imageList: [chat.content],
      selectedIndex: 0,
      onShowAction: () => {
        this.previewingImageMid = chat.mid;
      },
      onBackToFirstPage: () => {
        this.previewingImageMid = -1;
      }
    });
  }

  toggleHeader(hide: boolean) {
    AppUtil.getUIContext()
      .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring },
        () => {
          this.isHideNavBar = hide;
        })
  }

  backPage() {
    AppUtil.getUIContext()
      .animateTo({ curve: CommonConstant.AnimationCurveSpring, duration: CommonConstant.AnimationDurationNormal },
        () => {
          RouterUtil.pop(undefined, false, this.stackName);
        })
  }
}
