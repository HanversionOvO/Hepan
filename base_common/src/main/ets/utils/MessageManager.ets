import { LogUtil } from '@pura/harmony-utils';
import { MessageApi } from '../api/MessageApi';
import {
  MessageSummary, NewChat, NewMessagesSummary, RecentMessage,
} from '../api/models/MessageModels';

const TAG = '[MessageManager]: ';

export class MessageManager {
  private static instance: MessageManager;
  private timer: number = -1;
  private listeners: ((summary: NewMessagesSummary) => void)[] = [];
  private messageListListeners: ((list: RecentMessage[]) => void)[] = [];
  private lastSummary: NewMessagesSummary = new NewMessagesSummary();
  private messageList: RecentMessage[] = [];
  private currentPage: number = 1;

  public static getInstance(): MessageManager {
    if (!MessageManager.instance) {
      MessageManager.instance = new MessageManager();
    }
    return MessageManager.instance;
  }

  public start() {
    if (this.timer !== -1) {
      return;
    }
    LogUtil.info(TAG, 'Message polling service started');
    this.fetchData();
    this.timer = setInterval(() => {
      this.fetchData();
    }, 10000);
  }

  public stop() {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }

  // 刷新全量列表
  public async refreshMessageList() {
    try {
      this.currentPage = 1; // 重置页码
      // 显式传递第一页
      const rawList = await MessageApi.getMessageList(1);
      // 转换为类实例
      this.messageList = rawList.map(item => new RecentMessage(item));
      this.notifyMessageListListeners(this.messageList);
    } catch (error) {
      LogUtil.error(TAG, `Refresh message list failed: ${JSON.stringify(error)}`);
      // 这里不抛出异常，以免打断轮询逻辑
    }
  }

  public async loadNextPage() {
    try {
      const nextPage = this.currentPage + 1;
      const rawList = await MessageApi.getMessageList(nextPage);

      if (rawList && rawList.length > 0) {
        // 转换为类实例
        const newItems = rawList.map(item => new RecentMessage(item));
        // 追加到现有列表
        this.messageList = [...this.messageList, ...newItems];
        // 更新当前页码
        this.currentPage = nextPage;
        // 通知监听器更新 UI
        this.notifyMessageListListeners(this.messageList);
      } else {
        LogUtil.info(TAG, 'No more messages to load');
      }
    } catch (error) {
      LogUtil.error(TAG, `Load next page failed: ${JSON.stringify(error)}`);
    }
  }

  private async fetchData() {
    try {
      const summary: MessageSummary = await MessageApi.getMessageSummary();

      // 1. 更新消息计数通知
      const newSummary: NewMessagesSummary = summary.new_messages;
      this.lastSummary = newSummary;
      this.notifyListeners(newSummary);

      // 2. 如果有新到达的消息（增量更新），合并到列表
      if (summary.new_chats && summary.new_chats.length > 0) {
        this.mergeNewChats(summary.new_chats);
      }

      const serverUnreadCount = newSummary.chat;
      const localUnreadCount = this.messageList.filter(msg => msg.isNew === '1').length;

      if (serverUnreadCount < localUnreadCount) {
        LogUtil.info(TAG,
          `Sync mismatch detected (Server: ${serverUnreadCount}, Local: ${localUnreadCount}). Refreshing list to sync read status.`);
        await this.refreshMessageList();
      }

    } catch (error) {
      LogUtil.error(TAG, `Fetch message summary failed: ${JSON.stringify(error)}`);
    }
  }

  private mergeNewChats(newChats: NewChat[]) {
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

  public registerListener(listener: (summary: NewMessagesSummary) => void) {
    this.listeners.push(listener);
    if (this.lastSummary) {
      listener(this.lastSummary);
    }
  }

  public unregisterListener(listener: (summary: NewMessagesSummary) => void) {
    this.listeners = this.listeners.filter(l => l !== listener);
  }

  public registerMessageListListener(listener: (list: RecentMessage[]) => void) {
    this.messageListListeners.push(listener);
    if (this.messageList.length > 0) {
      listener(this.messageList);
    }
  }

  public unregisterMessageListListener(listener: (list: RecentMessage[]) => void) {
    this.messageListListeners = this.messageListListeners.filter(l => l !== listener);
  }

  private notifyListeners(summary: NewMessagesSummary) {
    this.listeners.forEach(listener => listener(summary));
  }

  private notifyMessageListListeners(list: RecentMessage[]) {
    this.messageListListeners.forEach(listener => listener(list));
  }
}