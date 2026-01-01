import { FriendUser, UserProfileData, UserSummary } from '../api/models/UserModels';
import { LogUtil } from '@pura/harmony-utils';

const TAG = '[UserModel]';

@ObservedV2
export class UserModel {
  @Trace userSummary: UserSummary | null = null;
  @Trace userProfile: UserProfileData | null = null;
  @Trace userFriends: FriendUser | null = null;

  /**
   * 更新用户摘要信息
   */
  public setUserSummary(summary: UserSummary): void {
    this.userSummary = summary;
    LogUtil.info(TAG, `User summary updated for: ${summary.username}`);
  }

  /**
   * 更新用户详情信息
   */
  public setUserProfile(profile: UserProfileData): void {
    this.userProfile = profile;
    LogUtil.info(TAG, `User profile updated for: ${profile.user_summary?.username}`);
  }

  /**
   * 清除用户信息 (登出时调用)
   */
  public clear(): void {
    this.userSummary = null;
    this.userProfile = null;
  }
}