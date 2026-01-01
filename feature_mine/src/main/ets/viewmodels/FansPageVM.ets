import { AppUtil, LogUtil } from '@pura/harmony-utils';
import { BaseVM, CommonConstant, InterestingUser, RecentVisitor, UserApi, UserFriends } from 'base_common';
import { CustomTabItem } from 'base_ui';

const TAG = '[FansPageVM]: '

@ObservedV2
export class FansPageVM extends BaseVM {
  @Trace isHideTitleBar: boolean = false;
  @Trace currentFansTabIndex: number = 0;
  @Trace currentFriendsPage: number = 1;
  @Trace isFansTabRefreshing: boolean = false;
  @Trace fansPageTabController: TabsController = new TabsController();
  @Trace fansPageTabItems: CustomTabItem[] = [
    { label: $r('app.string.FansPage_friends'), icon: $r('sys.symbol.person_badge_plus') },
    { label: $r('app.string.FansPage_visitor'), icon: $r('sys.symbol.person_2') },
  ];
  @Trace recommendList: InterestingUser[] = [];
  @Trace friendsList: UserFriends[] = [];
  @Trace visitorsList: RecentVisitor[] = [];

  async loadData(isInit: boolean = false) {
    // 1. 如果是初始化，显示 Loading 状态
    if (isInit) {
      this.showLoading();
    }

    let isSuccess = false;

    // 加载好友列表和推荐列表
    try {
      const friendsPromise = UserApi.getUserFriends(this.currentFriendsPage);
      const recommendPromise = UserApi.getInterestedUser();

      this.friendsList = await friendsPromise;
      this.recommendList = await recommendPromise;
      isSuccess = true; // 只要有一个接口成功，我们暂且认为成功，UI上显示空也可以
      LogUtil.debug(TAG, 'Friends loaded');
    } catch (error) {
      LogUtil.error(TAG, 'Failed to load friends: ' + JSON.stringify(error));
    }

    // 加载访客列表
    try {
      this.visitorsList = await UserApi.getUserVisitors();
      isSuccess = true;
      LogUtil.debug(TAG, 'Visitors loaded');
    } catch (error) {
      LogUtil.error(TAG, 'Failed to load visitors: ' + JSON.stringify(error));
    }

    // 2. 根据数据结果更新 UI 状态
    if (isSuccess) {
      // 简单判断：如果两个列表都为空，则显示 Empty，否则显示 Success
      // 注意：这里需要根据你的业务逻辑调整，比如只看当前 Tab 的数据
      const hasData = this.friendsList.length > 0 || this.visitorsList.length > 0 || this.recommendList.length > 0;

      if (hasData) {
        this.showSuccess();
      } else {
        this.showEmpty();
      }
    } else {
      // 如果所有尝试都失败了（isSuccess 还是 false），显示错误页
      this.showError();
    }

    // 确保刷新状态结束
    this.isFansTabRefreshing = false;
  }

  async refreshFansPage() {
    // 下拉刷新时，不需要显示全屏 loading，传入 false
    await this.loadData(false);
  }

  async startFansPage(param: string) {
    // 页面进入时，显示全屏 loading，传入 true
    await this.loadData(true);
  }

  async loadMore() {
    try {
      if (this.currentFansTabIndex === 0) {
        const moreFriends: UserFriends[] = await UserApi.getUserFriends(this.currentFriendsPage + 1);
        if (moreFriends.length > 0) {
          this.friendsList = this.friendsList.concat(moreFriends);
          this.currentFriendsPage++;
        }
      }
    } catch (error) {
    }
  }

  changeFansTab(index: number) {
    this.currentFansTabIndex = index;
    this.toggleHeader(false);
  }

  toggleHeader(hide: boolean) {
    AppUtil.getUIContext()
      .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring },
        () => {
          this.isHideTitleBar = hide;
        })
  }
}