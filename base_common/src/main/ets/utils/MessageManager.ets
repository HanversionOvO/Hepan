import { LogUtil, NotificationBasicOptions, NotificationUtil } from '@pura/harmony-utils';
import { MessageApi } from '../api/MessageApi';
import {
  MessageSummary,
  NewChat,
  NewMessagesSummary,
  RecentMessage,
  SystemSummary
} from '../api/models/MessageModels';
import { StorageManager } from './StorageManager';

const TAG = '[MessageManager]: ';

class NotificationCounts {
  at: number = 0;
  reply: number = 0;
  notice: number = 0;
  chat: number = 0;
}

class NotificationIds {
  at: number = 9101;
  reply: number = 9102;
  notice: number = 9103;
  chat: number = 9104;
}

export class MessageManager {
  private static instance: MessageManager;
  private timer: number = -1;
  private listeners: Array<(summary: NewMessagesSummary) => void> = [];
  private messageListListeners: Array<(list: RecentMessage[]) => void> = [];
  private lastSummary: NewMessagesSummary = new NewMessagesSummary();
  private hasInitialSummary: boolean = false;
  private lastNotifyCounts: NotificationCounts = new NotificationCounts();
  private lastBadgeCount: number = 0;
  private readonly notifyIds: NotificationIds = new NotificationIds();
  private lastChatSignature: string = '';
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
    if (!this.isLoggedIn()) {
      this.stop();
      return;
    }
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
    this.resetNotificationState();
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
    if (!this.isLoggedIn()) {
      this.stop();
      return;
    }
    this.isFetching = true;
    try {
      const summary: MessageSummary = await MessageApi.getMessageSummary();

      const newSummary: NewMessagesSummary = summary.new_messages;
      this.lastSummary = newSummary;
      this.notifyListeners(newSummary);

      await this.syncNotifications(newSummary, summary.new_chats ?? []);

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
      if (this.isAuthError(error)) {
        this.stop();
        return;
      }
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
    listener(this.lastSummary);
  }

  public unregisterListener(listener: (summary: NewMessagesSummary) => void): void {
    this.listeners = this.listeners.filter(l => l !== listener);
  }

  public registerMessageListListener(listener: (list: RecentMessage[]) => void): void {
    if (!this.messageListListeners.includes(listener)) {
      this.messageListListeners = [...this.messageListListeners, listener];
    }
    listener(this.messageList);
  }

  public unregisterMessageListListener(listener: (list: RecentMessage[]) => void): void {
    this.messageListListeners = this.messageListListeners.filter(l => l !== listener);
  }

  private notifyListeners(summary: NewMessagesSummary): void {
    this.listeners.forEach(listener => listener(summary));
  }

  private notifyMessageListListeners(list: RecentMessage[]): void {
    this.messageListListeners.forEach(listener => listener(list));
  }

  private isLoggedIn(): boolean {
    return StorageManager.authModel.isLoggedIn;
  }

  private resetNotificationState(): void {
    this.hasInitialSummary = false;
    this.lastNotifyCounts = new NotificationCounts();
    this.lastBadgeCount = 0;
    this.lastChatSignature = '';
    this.clearAllNotificationBadges();
  }

  private clearAllNotificationBadges(): void {
    this.clearBadge();
    this.cancelNotification(this.notifyIds.at);
    this.cancelNotification(this.notifyIds.reply);
    this.cancelNotification(this.notifyIds.notice);
    this.cancelNotification(this.notifyIds.chat);
  }

  private async syncNotifications(summary: NewMessagesSummary, newChats: NewChat[]): Promise<void> {
    const counts = this.buildNotificationCounts(summary);
    this.updateBadge(counts);

    if (!this.hasInitialSummary) {
      this.lastNotifyCounts = counts;
      this.hasInitialSummary = true;
      return;
    }

    const tasks: Promise<void>[] = [];

    if (counts.at > this.lastNotifyCounts.at) {
      const diff = counts.at - this.lastNotifyCounts.at;
      tasks.push(this.publishBasicNotification(
        this.notifyIds.at,
        '@Me',
        `New @Me: ${diff} (total ${counts.at})`
      ));
    } else if (counts.at === 0 && this.lastNotifyCounts.at > 0) {
      this.cancelNotification(this.notifyIds.at);
    }

    if (counts.reply > this.lastNotifyCounts.reply) {
      const diff = counts.reply - this.lastNotifyCounts.reply;
      tasks.push(this.publishBasicNotification(
        this.notifyIds.reply,
        'Reply',
        `New replies: ${diff} (total ${counts.reply})`
      ));
    } else if (counts.reply === 0 && this.lastNotifyCounts.reply > 0) {
      this.cancelNotification(this.notifyIds.reply);
    }

    if (counts.notice > this.lastNotifyCounts.notice) {
      const diff = counts.notice - this.lastNotifyCounts.notice;
      tasks.push(this.publishBasicNotification(
        this.notifyIds.notice,
        'Notification',
        `New notifications: ${diff} (total ${counts.notice})`
      ));
    } else if (counts.notice === 0 && this.lastNotifyCounts.notice > 0) {
      this.cancelNotification(this.notifyIds.notice);
    }

    if (counts.chat > this.lastNotifyCounts.chat) {
      const latestChat = this.getLatestChat(newChats);
      const chatSignature = latestChat ? `${latestChat.conversation_id}_${latestChat.last_dateline}` : '';
      if (!chatSignature || chatSignature !== this.lastChatSignature) {
        tasks.push(this.publishBasicNotification(
          this.notifyIds.chat,
          latestChat ? latestChat.last_author : 'Chat',
          this.buildChatPreview(latestChat)
        ));
        this.lastChatSignature = chatSignature;
      }
    } else if (counts.chat === 0 && this.lastNotifyCounts.chat > 0) {
      this.cancelNotification(this.notifyIds.chat);
      this.lastChatSignature = '';
    }

    if (tasks.length > 0) {
      await Promise.all(tasks);
    }

    this.lastNotifyCounts = counts;
  }

  private buildNotificationCounts(summary: NewMessagesSummary): NotificationCounts {
    const counts = new NotificationCounts();
    counts.at = Math.max(0, summary.posts.at);
    counts.reply = Math.max(0, summary.posts.reply);
    counts.notice = Math.max(0, this.sumSystemCounts(summary.system));
    counts.chat = Math.max(0, summary.chat);
    return counts;
  }

  private sumSystemCounts(system: SystemSummary): number {
    return system.friend + system.space + system.task + system.report + system.system + system.admin + system.app;
  }

  private updateBadge(counts: NotificationCounts): void {
    const total = counts.at + counts.reply + counts.notice + counts.chat;
    if (total === this.lastBadgeCount) {
      return;
    }
    this.lastBadgeCount = total;
    try {
      if (total > 0) {
        NotificationUtil.setBadge(total);
      } else {
        this.clearBadge();
      }
    } catch (error) {
      LogUtil.warn(TAG, `Update badge failed: ${this.stringifyError(error)}`);
    }
  }

  private clearBadge(): void {
    try {
      NotificationUtil.clearBadge();
    } catch (error) {
      LogUtil.warn(TAG, `Clear badge failed: ${this.stringifyError(error)}`);
    }
  }

  private getLatestChat(newChats: NewChat[]): NewChat | null {
    if (!newChats || newChats.length === 0) {
      return null;
    }
    let latest = newChats[0];
    for (let i = 1; i < newChats.length; i++) {
      const candidate = newChats[i];
      if (candidate.last_dateline > latest.last_dateline) {
        latest = candidate;
      }
    }
    return latest;
  }

  private buildChatPreview(chat: NewChat | null): string {
    if (!chat) {
      return 'New chat message';
    }
    const author = chat.last_author || 'Someone';
    const summary = chat.last_summary || 'sent a new message';
    return `${author}: ${summary}`;
  }

  private async publishBasicNotification(id: number, title: string, text: string): Promise<void> {
    try {
      const wantAgent = await NotificationUtil.getDefaultWantAgent();
      const options: NotificationBasicOptions = {
        id: id,
        title: title,
        text: text,
        wantAgent: wantAgent
      };
      await NotificationUtil.publishBasic(options);
    } catch (error) {
      LogUtil.warn(TAG, `Publish notification failed: ${this.stringifyError(error)}`);
    }
  }

  private cancelNotification(id: number): void {
    try {
      NotificationUtil.cancel(id);
    } catch (error) {
      LogUtil.warn(TAG, `Cancel notification failed: ${this.stringifyError(error)}`);
    }
  }

  private isAuthError(error: Object): boolean {
    const message = this.stringifyError(error);
    return message.includes('Not logged in') || message.includes('Auth failed') || message.includes('Unauthorized');
  }

  private stringifyError(error: Object): string {
    if (error instanceof Error) {
      return error.message;
    }
    if (typeof error === 'string') {
      return error;
    }
    try {
      return JSON.stringify(error);
    } catch {
      return String(error);
    }
  }
}
