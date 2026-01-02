import { AppUtil, LogUtil } from '@pura/harmony-utils';
import {
  AnPNotification,
  BaseVM,
  CommonConstant,
  MessageApi,
  RouterUtil,
  StackEnum,
  SystemNotification,
  UiState
} from 'base_common';
import { MessageNotifyCardItem } from '../components/MessageNotifyCard';

const TAG = '[NoticePageVM]: ';

@ObservedV2
export class NoticePageVM extends BaseVM {
  @Trace messageNotifyCard: MessageNotifyCardItem | undefined = undefined;
  @Trace isHideNavBar: boolean = false;
  @Trace isRefreshingNotice: boolean = false;
  @Trace currentPage: number = 1;
  @Trace hasMore: boolean = true;
  @Trace messageCards: AnPNotification[] = [];
  @Trace noticeCards: SystemNotification[] = [];

  async loadData(isInit: boolean = false) {
    if (isInit) {
      this.currentPage = 1;
      this.hasMore = true;
      this.uiState = UiState.LOADING;
    } else {
      this.isRefreshingNotice = true;
    }

    try {
      if (this.messageNotifyCard) {
        const type = this.messageNotifyCard.type;
        if (type === 'system') {
          this.noticeCards = await MessageApi.getSystemNotification();

          if (this.noticeCards.length === 0) {
            this.uiState = UiState.EMPTY;
          } else {
            this.uiState = UiState.SUCCESS;
          }
        } else {
          this.messageCards = await MessageApi.getNotificationList(type)

          if (this.messageCards.length === 0) {
            this.uiState = UiState.EMPTY;
          } else {
            this.uiState = UiState.SUCCESS;
          }
        }
      }
    } catch (error) {
      LogUtil.error(TAG, `Load data failed: ${JSON.stringify(error)}`);
      this.uiState = UiState.ERROR;
    } finally {
      this.isRefreshingNotice = false;
    }
  }

  async refreshData() {
    this.currentPage = 1;
    await this.loadData(false);
  }

  async loadMore() {
    try {
      if (this.messageNotifyCard) {
        const type = this.messageNotifyCard.type;
        if (type === "system") {
          const noticeCards: SystemNotification[] = await MessageApi.getSystemNotification(this.currentPage + 1);

          if (noticeCards.length > 0) {
            this.noticeCards = this.noticeCards.concat(noticeCards);
            this.currentPage++;
          }
        } else {
          const messageCards: AnPNotification[] = await MessageApi.getNotificationList(type, this.currentPage + 1);

          if (messageCards.length > 0) {
            this.messageCards = this.messageCards.concat(messageCards);
            this.currentPage++;
          }
        }
      }
    } catch (error) {
      LogUtil.error(TAG, 'Load more failed');
    }
  }

  toggleHeader(hide: boolean) {
    AppUtil.getUIContext()
      .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring },
        () => {
          this.isHideNavBar = hide;
        })
  }

  backPage() {
    AppUtil.getUIContext()
      .animateTo({ curve: CommonConstant.AnimationCurveSpring, duration: CommonConstant.AnimationDurationNormal },
        () => {
          RouterUtil.pop(undefined, false, StackEnum.MESSAGE);
        })
  }
}