import { AnPNotification, BaseVM, MessageApi } from 'base_common';
import { MessageNotifyCardItem } from '../components/MessageNotifyCard';

@ObservedV2
export class NoticePageVM extends BaseVM {
  @Trace messageNotifyCard: MessageNotifyCardItem | undefined = undefined;
  @Trace isHideNavBar: boolean = false;
  @Trace isRefreshingNotice: boolean = false;
  @Trace messageCards: AnPNotification[] = [];

  async startNoticePage() {
    if (this.messageNotifyCard) {
      const type = this.messageNotifyCard.type;
      if (type === 'system') {

      } else {
        this.messageCards = await MessageApi.getNotificationList(type)
      }
    }
  }
}