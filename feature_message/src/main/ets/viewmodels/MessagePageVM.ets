import { AppUtil } from '@pura/harmony-utils';
import {
  BaseVM,
  CommonConstant,
  MessageManager,
  NewMessagesSummary,
  RecentMessage,
  RouterMap,
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
  @Trace messagePageScroller: Scroller = new Scroller();
  @Trace titleButtons: NavTitleButtonModel[] = [
    {
      icon: $r('sys.symbol.person_badge_plus'), onClick: () => {
    }
    }
  ]
  @Trace messageNotifyCards: MessageNotifyCardItem[] = [
    new MessageNotifyCardItem(
      'at',
      0,
      $r('sys.symbol.at'),
      CommonConstant.ThemeColor,
      $r('app.string.MessagePage_at_me'),
      () => {
        this.clearAndPush(RouterMap.NOTICE_PAGE, this.messageNotifyCards[0]);
      }
    ),
    new MessageNotifyCardItem(
      'post',
      0,
      $r('sys.symbol.ellipsis_message'),
      CommonConstant.SuccessColor,
      $r('app.string.MessagePage_reply'),
      () => {
        this.clearAndPush(RouterMap.NOTICE_PAGE, this.messageNotifyCards[1]);
      }
    ),
    new MessageNotifyCardItem(
      'system',
      0,
      $r('sys.symbol.bell'),
      CommonConstant.WarningColor,
      $r('app.string.MessagePage_notification'),
      () => {
        this.clearAndPush(RouterMap.NOTICE_PAGE, this.messageNotifyCards[2]);
      }
    ),
  ];
  @Trace messages: RecentMessage[] = [];
  private messageListListener = (list: RecentMessage[]) => {
    this.messages = [...list];
  };
  private messageCountListener = (newMessages: NewMessagesSummary) => {
    this.updateMessageCounts(newMessages);
  };

  updateMessageCounts(newMessages: NewMessagesSummary) {
    this.messageNotifyCards[0].count = newMessages.posts.at;
    this.messageNotifyCards[1].count = newMessages.posts.reply;
    this.messageNotifyCards[2].count =
      newMessages.posts.rate + newMessages.posts.other + newMessages.system.system + newMessages.system.friend;
  }

  constructor() {
    super();
    // 注册监听器
    MessageManager.getInstance().registerListener(this.messageCountListener);
    MessageManager.getInstance().registerMessageListListener(this.messageListListener);
  }

  private clearAndPush(name: RouterMap, param: Object) {
    AppUtil.getUIContext()
      .animateTo({ curve: CommonConstant.AnimationCurveSpring, duration: CommonConstant.AnimationDurationNormal },
        () => {
          RouterUtil.replacePathByName(name, param, false, StackEnum.MESSAGE);
        })
  }

  pushToChatPage(index: number) {
    this.clearAndPush(RouterMap.CHAT_PAGE, this.messages[index]);
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

  async onRefresh() {
    await this.refreshMessages();
    this.isRefreshingMessage = false;
  }

  async loadMore() {
    //TODO: 加载更多
  }

  toggleHeader(hide: boolean) {
    AppUtil.getUIContext()
      .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring },
        () => {
          this.isHideSearch = hide;
        })
  }
}