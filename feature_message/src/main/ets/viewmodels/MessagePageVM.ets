import { LogUtil } from '@pura/harmony-utils';
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
  // 消息列表监听器
  private messageListListener = (list: RecentMessage[]) => {
    LogUtil.debug(TAG, JSON.stringify(list));
    
    this.messages = [...list];
  };
  private messageCountListener = (newMessages: NewMessagesSummary) => {
    this.updateMessageCounts(newMessages);
  };

  updateMessageCounts(newMessages: NewMessagesSummary) {
    this.messageNotifyCards[0].count = newMessages.posts.at;
    this.messageNotifyCards[1].count = newMessages.posts.reply;
    this.messageNotifyCards[2].count = newMessages.posts.rate + newMessages.posts.other + newMessages.system.system;
  }

  constructor() {
    super();
    // 注册监听器
    MessageManager.getInstance().registerListener(this.messageCountListener);
    MessageManager.getInstance().registerMessageListListener(this.messageListListener);
  }

  async startMessage() {
    MessageManager.getInstance().start();
    await this.refreshMessages();
  }

  async refreshMessages() {
    try {
      await MessageManager.getInstance().refreshMessageList();
    } catch (e) {
      // Error handling
    } finally {
    }
  }
}