import { LogUtil, NotificationBasicOptions, NotificationUtil } from '@pura/harmony-utils';
import { MessageApi } from '../api/MessageApi';
import {
  AnPNotification,
  MessageSummary,
  NewChat,
  NewMessagesSummary,
  PostSummary,
  RecentMessage,
  SystemNotification,
  SystemSummary
} from '../api/models/MessageModels';
import { StorageManager } from './StorageManager';

const TAG = '[MessageManager]: ';

interface NotificationContent {
  title: string;
  text: string;
}

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
  private isInForeground: boolean = true;
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

  public setForegroundState(isForeground: boolean): void {
    this.isInForeground = isForeground;
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

  public removeConversation(uid: number): void {
    if (!uid) {
      return;
    }
    const nextList = this.messageList.filter(item => item.toUserId !== uid);
    if (nextList.length !== this.messageList.length) {
      this.messageList = nextList;
      this.notifyMessageListListeners(this.messageList);
    }
  }

  public findConversation(uid: number): RecentMessage | null {
    if (!uid) {
      return null;
    }
    const match = this.messageList.find(item => item.toUserId === uid);
    return match ?? null;
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
      tasks.push(this.publishAtNotification());
    } else if (counts.at === 0 && this.lastNotifyCounts.at > 0) {
      this.cancelNotification(this.notifyIds.at);
    }

    if (counts.reply > this.lastNotifyCounts.reply) {
      tasks.push(this.publishReplyNotification());
    } else if (counts.reply === 0 && this.lastNotifyCounts.reply > 0) {
      this.cancelNotification(this.notifyIds.reply);
    }

    if (counts.notice > this.lastNotifyCounts.notice) {
      tasks.push(this.publishSystemNotification());
    } else if (counts.notice === 0 && this.lastNotifyCounts.notice > 0) {
      this.cancelNotification(this.notifyIds.notice);
    }

    if (counts.chat > this.lastNotifyCounts.chat) {
      const latestChat = this.getLatestChat(newChats);
      const chatSignature = latestChat ? `${latestChat.conversation_id}_${latestChat.last_dateline}` : '';
      if (!chatSignature || chatSignature !== this.lastChatSignature) {
        tasks.push(this.publishChatNotification(latestChat));
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
    const posts: PostSummary = summary.posts ?? new PostSummary();
    const system: SystemSummary = summary.system ?? new SystemSummary();
    counts.at = this.toSafeNumber(posts.at);
    counts.reply = this.toSafeNumber(posts.reply);
    counts.notice = this.toSafeNumber(posts.rate) + this.toSafeNumber(posts.other) + this.sumSystemCounts(system);
    counts.chat = this.toSafeNumber(summary.chat);
    return counts;
  }

  private sumSystemCounts(system: SystemSummary): number {
    return this.toSafeNumber(system.friend)
      + this.toSafeNumber(system.space)
      + this.toSafeNumber(system.task)
      + this.toSafeNumber(system.report)
      + this.toSafeNumber(system.system)
      + this.toSafeNumber(system.admin)
      + this.toSafeNumber(system.app);
  }

  private updateBadge(counts: NotificationCounts): void {
    const total = counts.at + counts.reply + counts.notice + counts.chat;
    if (!Number.isFinite(total)) {
      LogUtil.warn(TAG, 'Skip badge update due to invalid count');
      return;
    }
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

  private async publishAtNotification(): Promise<void> {
    const content = await this.getLatestAtContent();
    if (!content) {
      await this.publishBasicNotification(this.notifyIds.at, '有人 @你了', '你有新的@我');
      return;
    }
    await this.publishBasicNotification(this.notifyIds.at, content.title, content.text);
  }

  private async publishReplyNotification(): Promise<void> {
    const content = await this.getLatestReplyContent();
    if (!content) {
      await this.publishBasicNotification(this.notifyIds.reply, '有人 回复了你', '你有新的回复');
      return;
    }
    await this.publishBasicNotification(this.notifyIds.reply, content.title, content.text);
  }

  private async publishSystemNotification(): Promise<void> {
    const content = await this.getLatestSystemContent();
    if (!content) {
      await this.publishBasicNotification(this.notifyIds.notice, '你有一条新通知', '请查看通知详情');
      return;
    }
    await this.publishBasicNotification(this.notifyIds.notice, content.title, content.text);
  }

  private async publishChatNotification(chat: NewChat | null): Promise<void> {
    const title = chat && chat.last_author ? chat.last_author : '私信';
    const text = chat ? this.formatReplyContent(chat.last_summary) : '你有新的私信';
    await this.publishBasicNotification(this.notifyIds.chat, title, text);
  }

  private async getLatestAtContent(): Promise<NotificationContent | null> {
    try {
      const list: AnPNotification[] = await MessageApi.getNotificationList('at', 1, 1);
      if (!list || list.length === 0) {
        return null;
      }
      const item = list[0];
      const author = item.reply_nick_name || '有人';
      const text = this.formatReplyContent(item.reply_content);
      return {
        title: `${author} @你了`,
        text: text || '你有新的@我'
      };
    } catch (error) {
      LogUtil.warn(TAG, `Fetch latest @ notification failed: ${this.stringifyError(error)}`);
      return null;
    }
  }

  private async getLatestReplyContent(): Promise<NotificationContent | null> {
    try {
      const list: AnPNotification[] = await MessageApi.getNotificationList('post', 1, 1);
      if (!list || list.length === 0) {
        return null;
      }
      const item = list[0];
      const author = item.reply_nick_name || '有人';
      const text = this.formatReplyContent(item.reply_content);
      return {
        title: `${author} 回复了你`,
        text: text || '你有新的回复'
      };
    } catch (error) {
      LogUtil.warn(TAG, `Fetch latest reply notification failed: ${this.stringifyError(error)}`);
      return null;
    }
  }

  private async getLatestSystemContent(): Promise<NotificationContent | null> {
    try {
      const list: SystemNotification[] = await MessageApi.getSystemNotification(1);
      if (!list || list.length === 0) {
        return null;
      }
      const item = list[0];
      const author = item.author && item.author.trim().length > 0 ? item.author : '系统';
      const text = this.formatReplyContent(item.message || item.html_message || '');
      return {
        title: `你有一条来自 ${author} 的通知`,
        text: text || '请查看通知详情'
      };
    } catch (error) {
      LogUtil.warn(TAG, `Fetch latest system notification failed: ${this.stringifyError(error)}`);
      return null;
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

  private toSafeNumber(value: number | string | undefined | null): number {
    if (typeof value === 'number') {
      return Number.isFinite(value) ? value : 0;
    }
    if (typeof value === 'string') {
      const parsed = parseInt(value, 10);
      return Number.isNaN(parsed) ? 0 : parsed;
    }
    return 0;
  }

  private formatReplyContent(content: string): string {
    if (!content) {
      return '';
    }
    const lines = content.split(/\r?\n/);
    const filteredLines = lines.filter(line => !line.trim().startsWith('>'));
    return filteredLines.join('\n').trim();
  }
}
