import { AppUtil } from '@pura/harmony-utils';
import {
  BaseVM,
  CommonConstant,
  MessageApi,
  MessageManager,
  NewMessagesSummary,
  RecentMessage,
  RouterMap,
  RouterUtil,
  StackEnum,
  ToastUtil
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
  private isListening: boolean = false;
  private deleteFormhash: string = '';
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
  }

  private registerListeners(): void {
    if (this.isListening) {
      return;
    }
    MessageManager.getInstance().registerListener(this.messageCountListener);
    MessageManager.getInstance().registerMessageListListener(this.messageListListener);
    this.isListening = true;
  }

  private unregisterListeners(): void {
    if (!this.isListening) {
      return;
    }
    MessageManager.getInstance().unregisterListener(this.messageCountListener);
    MessageManager.getInstance().unregisterMessageListListener(this.messageListListener);
    this.isListening = false;
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
    this.registerListeners();
    await this.refreshMessages();
  }

  stopMessage() {
    this.unregisterListeners();
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
    await MessageManager.getInstance().loadNextPage();
  }

  async deleteConversation(message: RecentMessage): Promise<void> {
    if (!message || !message.toUserId) {
      return;
    }

    let formhash = this.deleteFormhash;
    if (!formhash) {
      formhash = await MessageApi.getPmDeleteFormhash();
      this.deleteFormhash = formhash;
    }

    if (!formhash) {
      ToastUtil.showLightError('无法删除：formhash 为空');
      return;
    }

    const result = await MessageApi.deleteChatMessage(message.toUserId, formhash);
    if (result.success) {
      MessageManager.getInstance().removeConversation(message.toUserId);
      ToastUtil.showLightSuccess(`已删除与 ${message.toUserName} 的聊天消息`);
    } else {
      ToastUtil.showLightError(result.message || '删除失败');
    }
  }

  toggleHeader(hide: boolean) {
    AppUtil.getUIContext()
      .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring },
        () => {
          this.isHideSearch = hide;
        })
  }
}
