import { LogUtil } from '@pura/harmony-utils';
import { BaseVM, RouterMap, RouterUtil, StorageManager, UserApi } from 'base_common';
import { UserProfileData } from 'base_common/src/main/ets/api/models/UserModels';
import { UserStatsModel } from '../components/UserStats';

@ObservedV2
export class MinePageVM extends BaseVM {
  @Trace outerScrollScroller: Scroller = new Scroller();
  @Trace isSticky: boolean = false;
  @Trace user: UserProfileData | null = StorageManager.userModel.userProfile;
  @Trace userStats: UserStatsModel[] = []

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
        this.userStats.push({ label: "粉丝", count: fullProfile.user_summary.friends });
        this.userStats.push({ label: "关注", count: fullProfile.user_summary.digests });
      }

      LogUtil.info('MinePageVM', `Full profile fetched. Email: ${fullProfile.email}`);
    } else {
      LogUtil.warn('MinePageVM', 'Failed to fetch full user profile.');
    }
  }
}