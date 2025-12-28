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

  /**
   * [新增] 获取完整的用户个人资料
   * 包含摘要、详细信息(邮箱/签名等)以及最近访客
   * @param uid 用户ID，传 'me' 代表当前登录用户
   */
  public static async getFullUserProfile(uid: number | 'me'): Promise<UserProfileData | null> {
    try {
      // 拼接路径：使用 'me' 或具体数字，并请求摘要和访客信息
      const idStr = uid === 'me' ? 'me' : uid.toString();
      const path = `/_/user/${idStr}/profile?user_summary=1&visitors=1`;

      LogUtil.info(TAG, `Fetching full profile for: ${idStr}`);

      const response = await ApiClient.getInstance().request<BaseResponse<UserProfileData>>({
        path: path,
        method: http.RequestMethod.GET,
        includeAuthorization: true, // 必须带 Token 才能获取 email 等敏感信息
        includeCookie: true
      });

      if (response.status === 200 && response.data.code === 0 && response.data.data) {
        return response.data.data;
      } else {
        LogUtil.warn(TAG, `Fetch full profile failed: ${response.data?.message || 'Unknown error'}`);
        return null;
      }
    } catch (error) {
      LogUtil.error(TAG, 'Fetch full profile exception', JSON.stringify(error));
      return null;
    }
  }
}