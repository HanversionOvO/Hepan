import { BaseVM, CommonConstant, RouterUtil, StackEnum } from 'base_common';
import { NavTitleButtonModel } from 'base_ui';
import { MessageNotifyCardItem } from '../components/MessageNotifyCard';

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
    {
      count: 0,
      icon: $r('sys.symbol.at'),
      iconColor: CommonConstant.ThemeColor,
      cardTitle: $r('app.string.MessagePage_at_me'),
      onCardClick: () => {
      }
    },
    {
      count: 0,
      icon: $r('sys.symbol.ellipsis_message'),
      iconColor: CommonConstant.InfoColor,
      cardTitle: $r('app.string.MessagePage_reply'),
      onCardClick: () => {
      }
    },
    {
      count: 2,
      icon: $r('sys.symbol.bell'),
      iconColor: CommonConstant.SuccessColor,
      cardTitle: $r('app.string.MessagePage_notification'),
      onCardClick: () => {
      }
    },
  ];
}