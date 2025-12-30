import { LogUtil } from '@pura/harmony-utils';
import { BaseVM, RouterMap, RouterUtil, StorageManager, UserApi } from 'base_common';
import { UserProfileData } from 'base_common/src/main/ets/api/models/UserModels';
import { FeatureCardModel } from '../components/FeatureCard';
import { UserProfileMapping, UserProfileSheetItem } from '../components/UserProfileSheet';
import { UserStatsModel } from '../components/UserStats';

const TAG = '[MinePageVM]: '

@ObservedV2
export class MinePageVM extends BaseVM {
  @Trace outerScrollScroller: Scroller = new Scroller();
  @Trace isSticky: boolean = false;
  @Trace isShowSignatureSheet: boolean = false;
  @Trace isShowUserProfileSheet: boolean = false;
  @Trace user: UserProfileData | null = StorageManager.userModel.userProfile;
  @Trace userStats: UserStatsModel[] = [];
  @Trace featureCards: FeatureCardModel[] = [];

  async startMine() {
    try {
      // 1. 请求最新用户信息
      const fullProfile = await UserApi.getFullUserProfile('me');

      if (fullProfile && fullProfile.user_summary) {
        // 1. 更新完整的 Profile 数据 (给 this.user 使用)
        StorageManager.userModel.setUserProfile(fullProfile);

        // 2. 更新全局状态 (StorageManager 会处理持久化)
        StorageManager.userModel.setUserSummary(fullProfile.user_summary);

        // 3. 更新当前 ViewModel 状态
        this.user = StorageManager.userModel.userProfile;

        // 4. 刷新界面数据
        this.refreshDisplayData();

        LogUtil.info(TAG, `Full profile fetched. UID: ${fullProfile.user_summary.uid}`);
      }
    } catch (error) {
      LogUtil.error(TAG, 'Failed to fetch full user profile.', JSON.stringify(error));
      // ApiClient 已处理 401/未登录 跳转，这里只需处理其他网络错误（如提示重试）
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
        count: summary.friends
      });
      this.userStats.push({
        label: $r("app.string.MinePage_views"),
        count: summary.views
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
    if (!signature) {
      this.isShowSignatureSheet = false;
      return;
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
      // 检查值是否有效 (不为 null, undefined, 空字符串)
      // 注意：数字 0 是有效值，需要保留
      if (value !== null && value !== undefined && value !== '') {
        let displayValue: string | number = value;

        // 处理日期格式化
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
    if (!timestamp) return '';
    try {
      const date = new Date(timestamp * 1000);
      return date.toLocaleString(); // 或使用自定义格式逻辑
    } catch (e) {
      return timestamp.toString();
    }
  }
}