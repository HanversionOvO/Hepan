import { AppUtil, LogUtil } from '@pura/harmony-utils';
import { BaseVM, Chat, CommonConstant, MessageApi, RecentMessage, RouterUtil, StackEnum } from 'base_common';

const TAG = '[ChatPageVM]: ';

@ObservedV2
export class ChatPageVM extends BaseVM {
  @Trace isHideNavBar: boolean = false;
  @Trace isLoadingHistory: boolean = false;
  @Trace showNewMessageTip: boolean = false;
  @Trace chatScroller: Scroller = new Scroller();
  @Trace recentMessage: RecentMessage | undefined = undefined;
  @Trace richEditorController: RichEditorController = new RichEditorController();
  @Trace chats: Chat[] = [];
  isAtBottom: boolean = true;
  private timerId: number = -1;

  async startMessage() {
    await this.loadData();
    this.startListen();
  }

  async loadData() {
    if (this.recentMessage) {
      const chats: Chat[] = await MessageApi.getChat(this.recentMessage.toUserId, 0, 0, 10);
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
    if (!this.recentMessage || this.chats.length === 0) {
      return;
    }

    try {
      const lastMsg = this.chats[this.chats.length - 1];
      const startTime = Number(lastMsg.time);

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
          const insertCount = newChats.length;
          this.chats = [...newChats, ...this.chats];

          setTimeout(() => {
            this.chatScroller.scrollToIndex(insertCount);
          }, 0);
        }
      }
    } catch (e) {
      console.error(TAG, 'Load history failed: ', e);
    } finally {
      this.isLoadingHistory = false;
    }
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
          RouterUtil.pop(undefined, false, StackEnum.MESSAGE);
        })
  }
}