import { LogUtil } from '@pura/harmony-utils';
import { BaseVM, RouterMap, RouterUtil, UserApi } from 'base_common';
import { UserProfileData } from 'base_common/src/main/ets/api/models/UserModels';
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
  // 新增：刷新状态
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
  // 新增：用户ID，支持查看他人
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
      // 使用 this.uid 获取数据
      const fullProfile = await UserApi.getFullUserProfile(this.uid);

      if (fullProfile && fullProfile.user_summary) {
        this.user = fullProfile;

        // 4. 刷新界面数据
        this.refreshDisplayData();

        LogUtil.info(TAG, `Full profile fetched. UID: ${fullProfile.user_summary.uid}`);
      }
    } catch (error) {
      LogUtil.error(TAG, 'Failed to fetch full user profile.', JSON.stringify(error));
    } finally {
      // 新增：无论成功失败，都关闭刷新状态
      this.isRefreshing = false;
    }
  }

  /**
   * 刷新统计数据和功能卡片
   */
  private refreshDisplayData() {
    // 清空旧数据，防止重复添加
    this.userStats = [];
    this.featureCards = [];

    const summary = this.user?.user_summary;
    if (this.user && summary) {
      // 填充统计数据 (好友、访客)
      this.userStats.push({
        label: $r("app.string.MinePage_friends"),
        count: summary.friends,
        onClick: () => {
          // 携带 uid 跳转
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
          // 携带 uid 跳转
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

      // 填充功能卡片 (积分、勋章)
      this.featureCards.push({
        cardIcon: $r('sys.symbol.drop_fill'),
        cardTitle: $r('app.string.MinePage_water'),
        cardCount: summary.ext_credits["水滴"],
      });
      this.featureCards.push({
        cardIcon: $r('sys.symbol.medal'),
        cardTitle: $r('app.string.MinePage_medal'),
        cardCount: summary.medals?.length ?? 0
      });
    }
  }

  // 修改签名
  async editSignature(signature: ResourceStr) {
    // 权限校验：仅本人可修改
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

  // 获取过滤用户信息
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
          displayValue = this.formatDate(value);
        }

        list.push({
          title: $r(`app.string.MinePage_userprofile_${item.suffix}`),
          value: displayValue
        });
      }
    });

    return list;
  }

  private formatDate(timestamp: number): string {
    if (!timestamp) {
      return '';
    }
    try {
      const date = new Date(timestamp * 1000);
      return date.toLocaleString();
    } catch (e) {
      return timestamp.toString();
    }
  }

  changeUserPostTab(index: number) {
    this.currentUserPostTabIndex = index;
  }
}