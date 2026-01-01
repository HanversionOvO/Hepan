import { LogUtil } from '@pura/harmony-utils';
import { BaseVM, DateUtil, RouterMap, RouterUtil, UserApi } from 'base_common';
import { Medal, UserProfileData } from 'base_common/src/main/ets/api/models/UserModels';
import { FeatureCardModel } from '../components/FeatureCard';
import { UserProfileMapping, UserProfileSheetItem } from '../components/UserProfileSheet';
import { UserStatsModel } from '../components/UserStats';
import { CustomTabItem } from 'base_ui';

const TAG = '[MinePageVM]: '

@ObservedV2
export class MinePageVM extends BaseVM {
  @Trace outerScrollScroller: Scroller = new Scroller();
  @Trace userPostTabController: TabsController = new TabsController();
  @Trace isSticky: boolean = false;
  @Trace isTabBarGlass: boolean = false;
  @Trace isShowSignatureSheet: boolean = false;
  @Trace isShowUserProfileSheet: boolean = false;
  // 新增：勋章 Sheet 显示状态
  @Trace isShowMedalSheet: boolean = false;
  // 新增：所有勋章列表
  @Trace allMedals: Medal[] = [];
  @Trace isRefreshing: boolean = false;
  @Trace user: UserProfileData | null = null;
  @Trace userStats: UserStatsModel[] = [];
  @Trace featureCards: FeatureCardModel[] = [];
  @Trace userPostTabItems: CustomTabItem[] = [
    { label: $r('app.string.MinePage_mine_post'), icon: $r('sys.symbol.book_closed_right_left') },
    { label: $r('app.string.MinePage_mine_reply'), icon: $r('sys.symbol.message') },
    { label: $r('app.string.MinePage_mine_star'), icon: $r('sys.symbol.star') },
  ]
  @Trace currentUserPostTabIndex: number = 0;
  @Trace uid: number | 'me' = 'me';

  @Computed
  get isMe(): boolean {
    return this.uid === 'me';
  }

  init(uid: number | 'me') {
    this.uid = uid;
  }

  async startMine() {
    await this.refreshData();
  }

  async refreshData() {
    try {
      const fullProfile = await UserApi.getFullUserProfile(this.uid);

      if (fullProfile && fullProfile.user_summary) {
        this.user = fullProfile;
        this.refreshDisplayData();
        LogUtil.info(TAG, `Full profile fetched. UID: ${fullProfile.user_summary.uid}`);
      }
    } catch (error) {
      LogUtil.error(TAG, 'Failed to fetch full user profile.', JSON.stringify(error));
    } finally {
      this.isRefreshing = false;
    }
  }

  // 新增：加载所有勋章
  async loadMedals() {
    if (this.allMedals.length > 0) {
      return;
    }
    try {
      const medals = await UserApi.getMedals();
      this.allMedals = medals;
    } catch (error) {
      LogUtil.error(TAG, 'Failed to load medals', JSON.stringify(error));
    }
  }

  private refreshDisplayData() {
    this.userStats = [];
    this.featureCards = [];

    const summary = this.user?.user_summary;
    if (this.user && summary) {
      this.userStats.push({
        label: $r("app.string.MinePage_friends"),
        count: summary.friends,
        onClick: () => {
          RouterUtil.pushPathByName(RouterMap.FANS, {
            "tab": "fan",
            "uid": this.uid
          } as Record<string, Object>);
        }
      });
      this.userStats.push({
        label: $r("app.string.MinePage_views"),
        count: summary.views,
        onClick: () => {
          RouterUtil.pushPathByName(RouterMap.FANS, {
            "tab": "visitor",
            "uid": this.uid
          } as Record<string, Object>);
        }
      });
      this.userStats.push({
        label: $r("app.string.MinePage_online_time"),
        count: this.user.online_time
      })

      this.featureCards.push({
        cardIcon: $r('sys.symbol.drop_fill'),
        cardTitle: $r('app.string.MinePage_water'),
        cardCount: summary.ext_credits["水滴"],
      });
      this.featureCards.push({
        cardIcon: $r('sys.symbol.medal'),
        cardTitle: $r('app.string.MinePage_medal'),
        cardCount: summary.medals?.length ?? 0,
        // 新增：点击打开勋章 Sheet
        onClick: () => {
          this.isShowMedalSheet = true;
          this.loadMedals();
        }
      });
    }
  }

  // ... (editSignature, getFilteredUserProfile, formatDate, changeUserPostTab 保持不变) ...
  async editSignature(signature: ResourceStr) {
    if (!this.isMe) {
      this.isShowSignatureSheet = false;
      return;
    }
    if (!signature) {
      this.isShowSignatureSheet = false;
      return;
    }
    const result: boolean = await UserApi.editSignature(signature.toString());
    if (result) {
      this.isShowSignatureSheet = false;
      this.refreshData();
    }
  }

  getFilteredUserProfile(): UserProfileSheetItem[] {
    const list: UserProfileSheetItem[] = [];
    const user = this.user;
    const summary = user?.user_summary;

    if (!user || !summary) {
      return list;
    }

    const mapping: UserProfileMapping[] = [
      { val: summary.uid, suffix: 'uid', isDate: false },
      { val: summary.username, suffix: 'username', isDate: false },
      { val: summary.group_title, suffix: 'group_title', isDate: false },
      { val: summary.credits, suffix: 'credits', isDate: false },
      { val: summary.friends, suffix: 'friends', isDate: false },
      { val: summary.threads, suffix: 'threads', isDate: false },
      { val: summary.replies, suffix: 'replies', isDate: false },
      { val: summary.digests, suffix: 'digests', isDate: false },
      { val: summary.views, suffix: 'views', isDate: false },
      { val: user.email, suffix: 'email', isDate: false },
      { val: user.register_time, suffix: 'register_time', isDate: true },
      { val: user.introduction, suffix: 'introduction', isDate: false },
      { val: user.custom_title, suffix: 'custom_title', isDate: false },
      { val: user.signature, suffix: 'signature', isDate: false },
      { val: user.online_time, suffix: 'online_time', isDate: false },
      { val: user.last_visit, suffix: 'last_visit', isDate: true },
      { val: user.last_activity, suffix: 'last_activity', isDate: true },
      { val: user.last_post, suffix: 'last_post', isDate: true },
      { val: user.register_ip, suffix: 'register_ip', isDate: false },
      { val: user.last_ip, suffix: 'last_ip', isDate: false }
    ];

    mapping.forEach(item => {
      const value = item.val;
      if (value !== null && value !== undefined && value !== '') {
        let displayValue: string | number = value;
        if (item.isDate && typeof value === 'number') {
          displayValue = DateUtil.getRelativeTime(value);
        }
        list.push({
          title: $r(`app.string.MinePage_userprofile_${item.suffix}`),
          value: displayValue
        });
      }
    });
    return list;
  }

  changeUserPostTab(index: number) {
    this.currentUserPostTabIndex = index;
  }
}