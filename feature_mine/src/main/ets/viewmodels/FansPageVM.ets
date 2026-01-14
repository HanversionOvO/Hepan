import { AppUtil, LogUtil, ResUtil } from '@pura/harmony-utils';
import {
  BaseVM,
  CommonConstant,
  InterestingUser,
  RecentVisitor,
  ToastUtil,
  UiState,
  UserApi,
  UserFriends
} from 'base_common';
import { CustomTabItem } from 'base_ui';

const TAG = '[FansPageVM]: '

@ObservedV2
export class FansPageVM extends BaseVM {
  // === UI 状态与控制 ===
  @Trace isHideTitleBar: boolean = false;
  @Trace currentFansTabIndex: number = 0;
  @Trace isFansTabRefreshing: boolean = false;
  @Trace fansPageTabController: TabsController = new TabsController();
  @Trace fansPageTabItems: CustomTabItem[] = [
    { label: $r('app.string.FansPage_friends'), icon: $r('sys.symbol.person_badge_plus') },
    { label: $r('app.string.FansPage_visitor'), icon: $r('sys.symbol.person_2') },
  ];
  // === 数据列表 ===
  @Trace friendsList: UserFriends[] = [];
  @Trace visitorsList: RecentVisitor[] = [];
  @Trace recommendList: InterestingUser[] = [];
  @Trace lastRefreshTime: number = 0;
  // === 分页与环境 ===
  @Trace currentFriendsPage: number = 1;
  @Trace hasMore: boolean = true;
  // === 用户视角控制 ===
  @Trace uid: number | 'me' = 'me';

  @Computed
  get isMe(): boolean {
    return this.uid === 'me';
  }

  // === 方法实现 ===

  async loadData(isInit: boolean = false) {
    if (isInit) {
      this.currentFriendsPage = 1;
      this.hasMore = true;
      this.uiState = UiState.LOADING;
    } else {
      this.isFansTabRefreshing = true;
    }

    try {
      if (this.currentFansTabIndex === 0) {
        // 1. 加载好友
        const friends = await UserApi.getUserFriends(this.currentFriendsPage, this.uid);

        // 2. 加载推荐 (仅在第一页且是查看自己时加载)
        if (this.currentFriendsPage === 1 && this.isMe) {
          try {
            const recommend = await UserApi.getInterestedUser();
            this.recommendList = recommend;
          } catch (e) {
            LogUtil.warn(TAG, 'Failed to load recommend list');
          }
        } else if (!this.isMe) {
          this.recommendList = [];
        }

        if (isInit || this.currentFriendsPage === 1) {
          this.friendsList = friends;
        } else {
          this.friendsList.push(...friends);
        }

        if (this.friendsList.length === 0 && this.recommendList.length === 0) {
          this.uiState = UiState.EMPTY;
        } else {
          this.uiState = UiState.SUCCESS;
        }

      } else {
        // 3. 加载访客
        // 修改点：移除 if (this.isMe) 限制，允许加载任意用户的访客
        const visitors = await UserApi.getUserVisitors(this.uid);

        // 访客接口通常不分页，直接覆盖
        this.visitorsList = visitors;

        if (this.visitorsList.length === 0) {
          this.uiState = UiState.EMPTY;
        } else {
          this.uiState = UiState.SUCCESS;
        }
      }
      this.lastRefreshTime = Date.now();
    } catch (error) {
      LogUtil.error(TAG, `Load data failed: ${JSON.stringify(error)}`);
      this.uiState = UiState.ERROR;
    } finally {
      this.isFansTabRefreshing = false;
    }
  }

  async refreshFansPage() {
    this.currentFriendsPage = 1;
    await this.loadData(false);
  }

  async loadMore() {
    try {
      if (this.currentFansTabIndex === 0) {
        const moreFriends: UserFriends[] = await UserApi.getUserFriends(this.currentFriendsPage + 1, this.uid);
        if (moreFriends.length > 0) {
          this.friendsList = this.friendsList.concat(moreFriends);
          this.currentFriendsPage++;
        }
      }
    } catch (error) {
      LogUtil.error(TAG, 'Load more failed');
    }
  }

  async deleteFriend(uid: number, username: string) {
    if (!this.isMe) {
      return;
    }

    ToastUtil.showInfo(`${ResUtil.getStringSync($r('app.string.FansUserItem_is_delete_friend'))} ${username}`, true,
      $r('app.string.FansUserItem_delete_friend'), async () => {
        const result: boolean = await UserApi.deleteFriend(uid);

        if (result) {
          ToastUtil.showLightSuccess(`${ResUtil.getStringSync($r('app.string.FansUserItem_delete_friend_success'))} ${username}`)
          await this.refreshFansPage();
        }
      });
  }

  changeFansTab(index: number) {
    this.currentFansTabIndex = index;
    this.toggleHeader(false);

    // 修改点：移除 && this.isMe 判断，使得在他人主页切换 Tab 时也会触发加载
    if ((index === 0 && this.friendsList.length === 0) ||
      (index === 1 && this.visitorsList.length === 0)) {
      this.loadData(false);
    }
  }

  toggleHeader(hide: boolean) {
    AppUtil.getUIContext()
      .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring },
        () => {
          this.isHideTitleBar = hide;
        })
  }
}
