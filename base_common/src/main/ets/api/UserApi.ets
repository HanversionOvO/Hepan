import { ApiClient } from './ApiClient';
import { BaseResponse, UserProfileData } from './models/UserModels';
import http from '@ohos.net.http';
import { LogUtil } from '@pura/harmony-utils';

const TAG = '[UserApi]';

export class UserApi {
  /**
   * 获取用户资料
   * @param uid 用户ID
   * @returns UserProfileData 或 null
   */
  public static async getUserProfile(uid: number): Promise<UserProfileData | null> {
    try {
      // 构造请求路径，带上 user_summary=1 参数
      const path = `/_/user/${uid}/profile?user_summary=1`;

      const response = await ApiClient.getInstance().request<BaseResponse<UserProfileData>>({
        path: path,
        method: http.RequestMethod.GET,
        includeAuthorization: true, // 确保带上 Auth 头
        includeCookie: true         // 确保带上 Cookie
      });

      LogUtil.info(TAG, `Fetch status: ${response.status}`);

      if (response.status === 200 && response.data.code === 0) {
        return response.data.data;
      } else {
        LogUtil.error(TAG, `Fetch profile failed: ${response.data.message}`);
        return null;
      }
    } catch (error) {
      LogUtil.error(TAG, 'Fetch profile exception', JSON.stringify(error));
      return null;
    }
  }
}