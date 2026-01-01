import { BaseVM, RecentVisitor, UserApi, UserFriends } from 'base_common';
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
  @Trace recommendList: Record<string, string>[] = [];
  @Trace friendsList: UserFriends[] = [];
  @Trace visitorsList: RecentVisitor[] = [];

  async loadData() {
    try {
      this.friendsList = await UserApi.getUserFriends(this.currentFriendsPage);
      this.visitorsList = await UserApi.getUserVisitors();
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

  changeFansTab(index: number) {
    this.currentFansTabIndex = index;
  }
}