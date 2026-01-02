import { LogUtil } from '@pura/harmony-utils';
import { MessageApi } from '../api/MessageApi';
import { MessageSummary, NewChat, NewMessagesSummary, RecentMessage } from '../api/models/MessageModels';

const TAG = '[MessageManager]: ';

export class MessageManager {
  private static instance: MessageManager;
  private timer: number = -1;
  // 监听回调列表（消息计数）
  private listeners: ((summary: NewMessagesSummary) => void)[] = [];
  // 监听回调列表（消息列表）
  private messageListListeners: ((list: RecentMessage[]) => void)[] = [];
  // 缓存数据
  private lastSummary: NewMessagesSummary | null = null;
  private messageList: RecentMessage[] = [];

  // 获取单例
  public static getInstance(): MessageManager {
    if (!MessageManager.instance) {
      MessageManager.instance = new MessageManager();
    }
    return MessageManager.instance;
  }

  // 开启轮询服务
  public start() {
    if (this.timer !== -1) {
      return;
    }
    LogUtil.info(TAG, 'Message polling service started');
    // 立即请求一次
    this.fetchData();
    // 每隔 10 秒轮询一次
    this.timer = setInterval(() => {
      this.fetchData();
    }, 10000);
  }

  // 停止轮询服务
  public stop() {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
    LogUtil.info(TAG, 'Message polling service stopped');
  }

  // 主动刷新完整消息列表
  public async refreshMessageList() {
    try {
      const list = await MessageApi.getMessageList();
      // 获取到的是全新数组，直接赋值即可
      this.messageList = list;
      this.notifyMessageListListeners(this.messageList);
    } catch (error) {
      LogUtil.error(TAG, `Refresh message list failed: ${JSON.stringify(error)}`);
      throw new Error(error);
    }
  }

  // 执行网络请求
  private async fetchData() {
    try {
      const summary: MessageSummary = await MessageApi.getMessageSummary();

      // 1. 处理消息计数
      const newSummary: NewMessagesSummary = summary.new_messages;
      this.lastSummary = newSummary;
      this.notifyListeners(newSummary);

      // 2. 处理新消息列表 (new_chats)
      if (summary.new_chats && summary.new_chats.length > 0) {
        this.mergeNewChats(summary.new_chats);
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
      this.messageList = updatedList; // 更新内部缓存为新数组
      this.notifyMessageListListeners(this.messageList); // 通知监听器
    }
  }

  private convertNewChatToRecent(chat: NewChat): RecentMessage {
    return {
      plid: Number(chat.conversation_id),
      pmid: Number(chat.conversation_id),
      lastUserId: chat.last_author_id,
      lastUserName: chat.last_author,
      lastSummary: chat.last_summary,
      lastDateline: chat.last_dateline * 1000,
      toUserId: chat.to_uid,
      toUserName: chat.to_username,
      toUserAvatar: `https://bbs.uestc.edu.cn/uc_server/avatar.php?uid=${chat.to_uid}&size=middle`,
      toUserIsBlack: '0',
      isNew: chat.unread ? '1' : '0'
    };
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