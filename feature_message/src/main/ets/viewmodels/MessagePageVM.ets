import {
  BaseVM,
  CommonConstant,
  MessageManager,
  NewMessagesSummary,
  RecentMessage,
  RouterUtil,
  StackEnum
} from 'base_common';
import { NavTitleButtonModel } from 'base_ui';
import { MessageNotifyCardItem } from '../components/MessageNotifyCard';

const TAG = '[MessagePageVM]: '

@ObservedV2
export class MessagePageVM extends BaseVM {
  @Trace isHideSearch: boolean = false;
  @Trace isRefreshingMessage: boolean = false;
  @Trace messageStack: NavPathStack = RouterUtil.getStack(StackEnum.MESSAGE);
  @Trace messagePageScroller: Scroller = new Scroller();
  @Trace titleButtons: NavTitleButtonModel[] = [
    {
      icon: $r('sys.symbol.person_badge_plus'), onClick: () => {
    }
    }
  ]
  @Trace messageNotifyCards: MessageNotifyCardItem[] = [
    new MessageNotifyCardItem(
      0,
      $r('sys.symbol.at'),
      CommonConstant.ThemeColor,
      $r('app.string.MessagePage_at_me'),
      () => {
      }
    ),
    new MessageNotifyCardItem(
      0,
      $r('sys.symbol.ellipsis_message'),
      CommonConstant.SuccessColor,
      $r('app.string.MessagePage_reply'),
      () => {
      }
    ),
    new MessageNotifyCardItem(
      0,
      $r('sys.symbol.bell'),
      CommonConstant.WarningColor,
      $r('app.string.MessagePage_notification'),
      () => {
      }
    ),
  ];
  @Trace messages: RecentMessage[] = [];
  // 消息计数监听回调
  private messageCountListener = (newMessages: NewMessagesSummary) => {
    this.updateMessageCounts(newMessages);
  };
  // 消息列表监听回调
  private messageListListener = (list: RecentMessage[]) => {
    this.messages = list;
  };

  updateMessageCounts(newMessages: NewMessagesSummary) {
    this.messageNotifyCards[0].count = newMessages.posts.at;
    this.messageNotifyCards[1].count = newMessages.posts.reply;
    this.messageNotifyCards[2].count = newMessages.posts.rate + newMessages.posts.other + newMessages.system.system;
  }

  constructor() {
    super();
    // 注册监听
    MessageManager.getInstance().registerListener(this.messageCountListener);
    MessageManager.getInstance().registerMessageListListener(this.messageListListener);
  }

  async startMessage() {
    // 启动轮询服务
    MessageManager.getInstance().start();
    // 首次主动加载完整列表
    await this.refreshMessages();
  }

  async refreshMessages() {
    try {
      this.isRefreshingMessage = true;
      // 调用 Manager 的刷新方法，更新数据源
      await MessageManager.getInstance().refreshMessageList();
    } catch (e) {
      // 错误处理由 BaseVM 或 UI 提示
    } finally {
      this.isRefreshingMessage = false;
    }
  }
}