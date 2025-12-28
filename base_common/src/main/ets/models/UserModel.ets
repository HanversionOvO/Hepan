import { UserSummary } from '../api/models/UserModels';
import { LogUtil } from '@pura/harmony-utils';

const TAG = '[UserModel]';

@ObservedV2
export class UserModel {
  @Trace userSummary: UserSummary | null = null;

  /**
   * 更新用户摘要信息
   */
  public setUserSummary(summary: UserSummary): void {
    this.userSummary = summary;
    LogUtil.info(TAG, `User summary updated for: ${summary.username}`);
  }

  /**
   * 清除用户信息 (登出时调用)
   */
  public clear(): void {
    this.userSummary = null;
  }
}