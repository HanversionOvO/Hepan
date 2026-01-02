import { AppUtil } from '@pura/harmony-utils';
import { BaseVM, Chat, CommonConstant, MessageApi, RecentMessage, RouterUtil, StackEnum } from 'base_common';

const TAG = '[ChatPageVM]: ';

@ObservedV2
export class ChatPageVM extends BaseVM {
  @Trace isHideNavBar: boolean = false;
  @Trace isLoadingHistory: boolean = false;
  @Trace recentMessage: RecentMessage | undefined = undefined;
  @Trace richEditorController: RichEditorController = new RichEditorController();
  @Trace chats: Chat[] = [];

  async loadData() {
    if (this.recentMessage) {
      const chats: Chat[] = await MessageApi.getChat(this.recentMessage.toUserId, 0, 0, 10);

      this.chats = chats.sort((a, b) => Number(a.time) - Number(b.time));
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

      const historyChats: Chat[] = await MessageApi.getChat(this.recentMessage.toUserId, 0, stopTime, 10);

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