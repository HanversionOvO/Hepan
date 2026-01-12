import { AppUtil, LogUtil } from '@pura/harmony-utils';
import {
  AnPNotification,
  BaseVM,
  CommonConstant,
  ForumTieSummary,
  MessageApi,
  RouterMap,
  RouterUtil,
  StackEnum,
  SystemNotification,
  UiState
} from 'base_common';
import { LongTakeTransitionOptions } from 'base_ui/src/main/ets/transitions/longtake/utils/Options';
import { MessageNotifyCardItem } from '../components/MessageNotifyCard';
import { curves } from '@kit.ArkUI';
import { LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'base_ui';

const TAG = '[NoticePageVM]: ';

@ObservedV2
export class NoticePageVM extends BaseVM {
  @Trace messageNotifyCard: MessageNotifyCardItem | undefined = undefined;
  @Trace isHideNavBar: boolean = false;
  @Trace isRefreshingNotice: boolean = false;
  @Trace currentPage: number = 1;
  @Trace hasMore: boolean = true;
  private isLoadingMore: boolean = false;
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
          this.noticeCards = await MessageApi.getSystemNotification(this.currentPage);
          this.messageCards = [];
          this.hasMore = this.noticeCards.length > 0;

          if (this.noticeCards.length === 0) {
            this.uiState = UiState.EMPTY;
          } else {
            this.uiState = UiState.SUCCESS;
          }
        } else {
          this.messageCards = await MessageApi.getNotificationList(type);
          this.noticeCards = [];

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
    this.hasMore = true;
    await this.loadData(false);
  }

  async loadMore() {
    if (this.isLoadingMore || !this.hasMore) {
      return;
    }
    this.isLoadingMore = true;
    try {
      if (this.messageNotifyCard) {
        const type = this.messageNotifyCard.type;
        if (type === "system") {
          const nextPage = this.currentPage + 1;
          const noticeCards: SystemNotification[] = await MessageApi.getSystemNotification(nextPage);

          if (noticeCards.length > 0) {
            this.noticeCards = this.noticeCards.concat(noticeCards);
            this.currentPage = nextPage;
          } else {
            this.hasMore = false;
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
    } finally {
      this.isLoadingMore = false;
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

  private extractPidFromUrl(url: string): string {
    if (!url) {
      return '';
    }
    const pidMatch = /[?&]pid=(\d+)/.exec(url);
    if (pidMatch) {
      return pidMatch[1];
    }
    const hashMatch = /#pid(\d+)/.exec(url);
    return hashMatch ? hashMatch[1] : '';
  }

  private extractFloorFromUrl(url: string): number {
    if (!url) {
      return 0;
    }
    const floorMatch = /[?&](?:floor|position|postno)=(\d+)/.exec(url);
    if (floorMatch) {
      return Number(floorMatch[1]);
    }
    return 0;
  }

  enterDetailPage(item: AnPNotification, context: UIContext) {
    if (!item.topic_id) {
      return;
    }

    // 1. 构造 ForumTieSummary，用于详情页加载数据
    // 注意：通知中可能没有完整的帖子信息（如作者ID），这里只填必要字段
    const tieSummary = new ForumTieSummary();
    tieSummary.thread_id = item.topic_id;
    tieSummary.subject = item.topic_subject;
    tieSummary.author_id = 0; // 暂时置0，详情页会重新加载

    // 2. 构造一镜到底动画参数
    let options: LongTakeTransitionOptions = {
      onEnterTransitionStart: () => {
        context.animateTo({ curve: curves.springMotion(0.35, 0.75) }, () => {
        })
      },
      onBackTransitionStart: () => {
        context.animateTo({ curve: curves.springMotion(0.35, 0.75) }, () => {
        })
      }
    };

    // 生成动画参数，使用 topic_id 作为唯一标识
    let longTakeTransitionParam: LongTakeTransitionParam | undefined =
      LoneTakeAnimationsTransition.generateLongTakeParam(context,
        item.topic_id.toString(), CommonConstant.RadiusLarge, options);

    const params: Record<string, Object> = {};

    if (longTakeTransitionParam) {
      params["transition"] = longTakeTransitionParam;
    }

    params["tieSummary"] = tieSummary;

    // 3. 传入需要滚动的目标楼层PID (reply_remind_id 通常对应 pid)
    const targetFloor = this.extractFloorFromUrl(item.reply_url || '');
    if (targetFloor > 0) {
      params["targetFloor"] = targetFloor;
    } else if (item.reply_remind_id) {
      params["targetPid"] = item.reply_remind_id.toString();
    } else {
      const pidFromUrl = this.extractPidFromUrl(item.reply_url || '');
      if (pidFromUrl) {
        params["targetPid"] = pidFromUrl;
      }
    }

    // 4. 路由跳转
    RouterUtil.pushPathByName(RouterMap.TIE_CONTENT_PAGE, params);
  }
}
