import { LogUtil } from '@pura/harmony-utils';
import { MessageApi } from '../api/MessageApi';
// 引入新增的 RecentMessageData 接口
import {
  MessageSummary,
  NewChat,
  NewMessagesSummary,
  RecentMessage,
  RecentMessageData
} from '../api/models/MessageModels';

const TAG = '[MessageManager]: ';

export class MessageManager {
  private static instance: MessageManager;
  private timer: number = -1;
  private listeners: ((summary: NewMessagesSummary) => void)[] = [];
  private messageListListeners: ((list: RecentMessage[]) => void)[] = [];
  private lastSummary: NewMessagesSummary | null = null;
  // 缓存列表
  private messageList: RecentMessage[] = [];

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
      const rawList = await MessageApi.getMessageList();
      // 将普通对象转换为类的实例
      this.messageList = rawList.map(item => new RecentMessage(item as RecentMessageData));
      this.notifyMessageListListeners(this.messageList);
    } catch (error) {
      LogUtil.error(TAG, `Refresh message list failed: ${JSON.stringify(error)}`);
      throw new Error(error);
    }
  }

  private async fetchData() {
    try {
      const summary: MessageSummary = await MessageApi.getMessageSummary();
      const newSummary: NewMessagesSummary = summary.new_messages;
      this.lastSummary = newSummary;
      this.notifyListeners(newSummary);

      // 如果有新会话消息，合并到列表
      if (summary.new_chats && summary.new_chats.length > 0) {
        LogUtil.info(TAG, `Received ${summary.new_chats.length} new chats`);
        this.mergeNewChats(summary.new_chats);
      }
    } catch (error) {
      LogUtil.error(TAG, `Fetch message summary failed: ${JSON.stringify(error)}`);
    }
  }

  private mergeNewChats(newChats: NewChat[]) {
    // 关键：创建新数组副本，确保 ArkUI 能检测到引用变化
    const updatedList = [...this.messageList];
    let isListChanged = false;

    newChats.forEach(chat => {
      const plid = Number(chat.conversation_id);

      // 1. 查找是否存在同 ID 的旧消息
      const index = updatedList.findIndex(msg => msg.plid === plid);

      // 2. 转换新数据为对象实例
      const newMessage = this.convertNewChatToRecent(chat);

      if (index !== -1) {
        // 如果存在，移除旧的（为了将其移动到顶部或更新内容）
        updatedList.splice(index, 1);
      }

      // 3. 插入到顶部
      updatedList.unshift(newMessage);
      isListChanged = true;
    });

    if (isListChanged) {
      this.messageList = updatedList; // 更新缓存
      this.notifyMessageListListeners(this.messageList); // 通知 VM
    }
  }

  private convertNewChatToRecent(chat: NewChat): RecentMessage {
    // 修复：使用 as RecentMessageData 解决类型报错
    return new RecentMessage({
      plid: Number(chat.conversation_id),
      pmid: Number(chat.conversation_id),
      lastUserId: chat.last_author_id,
      lastUserName: chat.last_author,
      lastSummary: chat.last_summary,
      lastDateline: chat.last_dateline * 1000, // 秒转毫秒
      toUserId: chat.to_uid,
      toUserName: chat.to_username,
      toUserAvatar: `https://bbs.uestc.edu.cn/uc_server/avatar.php?uid=${chat.to_uid}&size=middle`,
      toUserIsBlack: '0',
      isNew: chat.unread ? '1' : '0'
    } as RecentMessageData);
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