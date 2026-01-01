import { AppUtil } from '@pura/harmony-utils';
import { BaseVM, CommonConstant, InterestingUser, RecentVisitor, UserApi, UserFriends } from 'base_common';
import { CustomTabItem } from 'base_ui';

const TAG = '[FansPageVM]: '

@ObservedV2
export class FansPageVM extends BaseVM {
  @Trace isHideTitleBar: boolean = false;
  @Trace currentFansTabIndex: number = 0;
  @Trace currentFriendsPage: number = 1;
  @Trace isFansTabRefreshing: boolean = false;
  @Trace fansTabScroller: Scroller = new Scroller();
  @Trace fansPageTabController: TabsController = new TabsController();
  @Trace fansPageTabItems: CustomTabItem[] = [
    { label: $r('app.string.FansPage_friends'), icon: $r('sys.symbol.person_badge_plus') },
    { label: $r('app.string.FansPage_visitor'), icon: $r('sys.symbol.person_2') },
  ];
  @Trace recommendList: InterestingUser[] = [];
  @Trace friendsList: UserFriends[] = [];
  @Trace visitorsList: RecentVisitor[] = [];

  async loadData() {
    try {
      if (this.currentFansTabIndex === 0) {
        this.recommendList = await UserApi.getInterestedUser();
        this.friendsList = await UserApi.getUserFriends(this.currentFriendsPage);
      } else {
        this.visitorsList = await UserApi.getUserVisitors();
      }
    } catch (error) {
    }
  }

  async refreshFansPage() {
    await this.loadData();
    this.isFansTabRefreshing = false;
  }

  async startFansPage(param: string) {
    await this.loadData();
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