import { LogUtil } from '@pura/harmony-utils';
import { MessageApi } from '../api/MessageApi';
import {
  MessageSummary,
  NewChat,
  NewMessagesSummary,
  RecentMessage
} from '../api/models/MessageModels';

const TAG = '[MessageManager]: ';

export class MessageManager {
  private static instance: MessageManager;
  private timer: number = -1;
  private listeners: Array<(summary: NewMessagesSummary) => void> = [];
  private messageListListeners: Array<(list: RecentMessage[]) => void> = [];
  private lastSummary: NewMessagesSummary = new NewMessagesSummary();
  private messageList: RecentMessage[] = [];
  private currentPage: number = 1;
  private readonly pageSize: number = 15;
  private hasMore: boolean = true;
  private isFetching: boolean = false;
  private isLoadingList: boolean = false;

  public static getInstance(): MessageManager {
    if (!MessageManager.instance) {
      MessageManager.instance = new MessageManager();
    }
    return MessageManager.instance;
  }

  public start(): void {
    if (this.timer !== -1) {
      return;
    }
    LogUtil.info(TAG, 'Message polling service started');
    this.fetchData();
    this.timer = setInterval(() => {
      this.fetchData();
    }, 10000);
  }

  public stop(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
      LogUtil.info(TAG, 'Message polling service stopped');
    }
  }

  private ensureRunning(): void {
    if (this.timer === -1) {
      this.start();
    }
  }

  private maybeStop(): void {
    if (this.listeners.length === 0 && this.messageListListeners.length === 0) {
      this.stop();
    }
  }

  public async refreshMessageList(): Promise<void> {
    if (this.isLoadingList) {
      return;
    }
    this.isLoadingList = true;
    try {
      this.currentPage = 1;
      this.hasMore = true;
      const rawList = await MessageApi.getMessageList(1, this.pageSize);
      this.messageList = rawList.map(item => new RecentMessage(item));
      this.notifyMessageListListeners(this.messageList);
      if (rawList.length < this.pageSize) {
        this.hasMore = false;
      }
    } catch (error) {
      LogUtil.error(TAG, `Refresh message list failed: ${JSON.stringify(error)}`);
    } finally {
      this.isLoadingList = false;
    }
  }

  public async loadNextPage(): Promise<void> {
    if (this.isLoadingList || !this.hasMore) {
      return;
    }
    this.isLoadingList = true;
    try {
      const nextPage = this.currentPage + 1;
      const rawList = await MessageApi.getMessageList(nextPage, this.pageSize);

      if (rawList && rawList.length > 0) {
        const newItems = rawList.map(item => new RecentMessage(item));
        this.messageList = [...this.messageList, ...newItems];
        this.currentPage = nextPage;
        this.notifyMessageListListeners(this.messageList);
        if (rawList.length < this.pageSize) {
          this.hasMore = false;
        }
      } else {
        this.hasMore = false;
        LogUtil.info(TAG, 'No more messages to load');
      }
    } catch (error) {
      LogUtil.error(TAG, `Load next page failed: ${JSON.stringify(error)}`);
    } finally {
      this.isLoadingList = false;
    }
  }

  private async fetchData(): Promise<void> {
    if (this.isFetching) {
      return;
    }
    this.isFetching = true;
    try {
      const summary: MessageSummary = await MessageApi.getMessageSummary();

      const newSummary: NewMessagesSummary = summary.new_messages;
      this.lastSummary = newSummary;
      this.notifyListeners(newSummary);

      if (summary.new_chats && summary.new_chats.length > 0) {
        this.mergeNewChats(summary.new_chats);
      }

      const serverUnreadCount = newSummary.chat;
      const localUnreadCount = this.messageList.filter(msg => msg.isNew === '1').length;

      if (serverUnreadCount < localUnreadCount) {
        LogUtil.info(TAG,
          `Sync mismatch detected (Server: ${serverUnreadCount}, Local: ${localUnreadCount}). Refreshing list to sync.`);
        await this.refreshMessageList();
      }

    } catch (error) {
      LogUtil.error(TAG, `Fetch message summary failed: ${JSON.stringify(error)}`);
    } finally {
      this.isFetching = false;
    }
  }

  private mergeNewChats(newChats: NewChat[]): void {
    const updatedList = [...this.messageList];
    let isListChanged = false;

    newChats.forEach(chat => {
      const plid = Number(chat.conversation_id);
      const index = updatedList.findIndex(msg => msg.plid === plid);

      const newMessage = this.convertNewChatToRecent(chat);

      if (index !== -1) {
        updatedList.splice(index, 1);
      }

      updatedList.unshift(newMessage);
      isListChanged = true;
    });

    if (isListChanged) {
      this.messageList = updatedList;
      this.notifyMessageListListeners(this.messageList);
    }
  }

  private convertNewChatToRecent(chat: NewChat): RecentMessage {
    const recentMessage = new RecentMessage();
    recentMessage.plid = Number(chat.conversation_id);
    recentMessage.pmid = Number(chat.conversation_id);
    recentMessage.lastUserId = chat.last_author_id;
    recentMessage.lastUserName = chat.last_author;
    recentMessage.lastSummary = chat.last_summary;
    recentMessage.lastDateline = chat.last_dateline * 1000;
    recentMessage.toUserId = chat.to_uid;
    recentMessage.toUserName = chat.to_username;
    recentMessage.toUserAvatar = `https://bbs.uestc.edu.cn/uc_server/avatar.php?uid=${chat.to_uid}&size=middle`;
    recentMessage.toUserIsBlack = '0';
    recentMessage.isNew = chat.unread ? '1' : '0';
    return recentMessage;
  }

  public registerListener(listener: (summary: NewMessagesSummary) => void): void {
    if (!this.listeners.includes(listener)) {
      this.listeners = [...this.listeners, listener];
    }
    this.ensureRunning();
    listener(this.lastSummary);
  }

  public unregisterListener(listener: (summary: NewMessagesSummary) => void): void {
    this.listeners = this.listeners.filter(l => l !== listener);
    this.maybeStop();
  }

  public registerMessageListListener(listener: (list: RecentMessage[]) => void): void {
    if (!this.messageListListeners.includes(listener)) {
      this.messageListListeners = [...this.messageListListeners, listener];
    }
    this.ensureRunning();
    listener(this.messageList);
  }

  public unregisterMessageListListener(listener: (list: RecentMessage[]) => void): void {
    this.messageListListeners = this.messageListListeners.filter(l => l !== listener);
    this.maybeStop();
  }

  private notifyListeners(summary: NewMessagesSummary): void {
    this.listeners.forEach(listener => listener(summary));
  }

  private notifyMessageListListeners(list: RecentMessage[]): void {
    this.messageListListeners.forEach(listener => listener(list));
  }
}
