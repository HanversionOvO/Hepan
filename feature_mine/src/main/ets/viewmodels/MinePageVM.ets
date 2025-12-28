import { LogUtil } from '@pura/harmony-utils';
import { BaseVM, RouterMap, RouterUtil, StorageManager, UserApi } from 'base_common';
import { UserProfileData } from 'base_common/src/main/ets/api/models/UserModels';
import { FeatureCardModel } from '../components/FeatureCard';
import { UserStatsModel } from '../components/UserStats';

@ObservedV2
export class MinePageVM extends BaseVM {
  @Trace outerScrollScroller: Scroller = new Scroller();
  @Trace isSticky: boolean = false;
  @Trace user: UserProfileData | null = StorageManager.userModel.userProfile;
  @Trace userStats: UserStatsModel[] = [];
  @Trace featureCards: FeatureCardModel[] = [];

  async startMine() {
    const authModel = StorageManager.authModel;
    if (!authModel.isLoggedIn) {
      LogUtil.info('MinePageVM', 'User not logged in, redirecting to login.');
      // 跳转到登录页
      RouterUtil.pushPathByName(RouterMap.LOGIN);
      return;
    }

    const fullProfile = await UserApi.getFullUserProfile('me');
    if (fullProfile) {
      if (fullProfile.user_summary) {
        StorageManager.userModel.setUserSummary(fullProfile.user_summary);
        this.userStats.push({ label: $r("app.string.MinePage_friends"), count: fullProfile.user_summary.friends });
        this.userStats.push({ label: $r("app.string.MinePage_views"), count: fullProfile.user_summary.views });

        this.featureCards.push({
          cardIcon: $r('sys.symbol.drop_fill'),
          cardTitle: $r('app.string.MinePage_water'),
          cardCount: this.user?.user_summary?.credits || 0,
        })
        this.featureCards.push({
          cardIcon: $r('sys.symbol.medal'),
          cardTitle: $r('app.string.MinePage_medal'),
          cardCount: this.user?.user_summary?.medals?.length || 0
        })
      }

      LogUtil.info('MinePageVM', `Full profile fetched. Email: ${fullProfile.email}`);
    } else {
      LogUtil.warn('MinePageVM', 'Failed to fetch full user profile.');
    }
  }
}