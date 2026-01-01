import { LogUtil } from '@pura/harmony-utils';
import { BaseVM, UserApi, UserFriends } from 'base_common';
import { CustomTabItem } from 'base_ui';
import { JSON } from '@kit.ArkTS';

const TAG = '[FansPageVM]: '

@ObservedV2
export class FansPageVM extends BaseVM {
  @Trace isHideTitleBar: boolean = false;
  @Trace currentFansTabIndex: number = 0;
  @Trace isFansTabRefreshing: boolean = false;
  @Trace fansTabScroller: Scroller = new Scroller();
  @Trace fansPageTabController: TabsController = new TabsController();
  @Trace fansPageTabItems: CustomTabItem[] = [
    { label: $r('app.string.FansPage_friends'), icon: $r('sys.symbol.person_badge_plus') },
    { label: $r('app.string.FansPage_visitor'), icon: $r('sys.symbol.person_2') },
  ];
  @Trace recommendList: Record<string, string>[] = [];
  @Trace friendsList: UserFriends[] = [];
  @Trace visitorsList: Record<string, string>[] = [];

  async loadData(): Promise<void> {
    try {
      this.friendsList = await UserApi.getUserFriends();
      LogUtil.info(TAG, JSON.stringify(this.friendsList));
    } catch (error) {

    }
  }

  async startFansPage() {
    await this.loadData();
  }

  changeFansTab(index: number) {
    this.currentFansTabIndex = index;
  }
}