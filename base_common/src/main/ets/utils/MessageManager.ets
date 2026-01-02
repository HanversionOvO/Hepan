import { LogUtil } from '@pura/harmony-utils';
import { MessageApi } from '../api/MessageApi';
import { MessageSummary, NewMessagesSummary } from '../api/models/MessageModels';

const TAG = '[MessageManager]: ';

export class MessageManager {
  private static instance: MessageManager;
  private timer: number = -1;
  // 监听回调列表
  private listeners: ((summary: NewMessagesSummary) => void)[] = [];
  // 缓存上一次的数据
  private lastSummary: NewMessagesSummary | null = null;

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
    // 每隔 10 秒轮询一次 (时间可根据需求调整)
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

  // 执行网络请求
  private async fetchData() {
    try {
      const summary: MessageSummary = await MessageApi.getMessageSummary();
      const newSummary: NewMessagesSummary = summary.new_messages;
      this.lastSummary = newSummary;
      this.notifyListeners(newSummary);
    } catch (error) {
      LogUtil.error(TAG, `Fetch message summary failed: ${JSON.stringify(error)}`);
    }
  }

  // 注册监听器
  public registerListener(listener: (summary: NewMessagesSummary) => void) {
    this.listeners.push(listener);
    // 如果已有缓存数据，注册时立即回调一次，保证 UI 及时显示
    if (this.lastSummary) {
      listener(this.lastSummary);
    }
  }

  // 移除监听器
  public unregisterListener(listener: (summary: NewMessagesSummary) => void) {
    this.listeners = this.listeners.filter(l => l !== listener);
  }

  // 通知所有监听者
  private notifyListeners(summary: NewMessagesSummary) {
    this.listeners.forEach(listener => listener(summary));
  }
}