import { ApiClient } from './ApiClient';
import { BaseResponse, UserProfileData } from './models/UserModels';
import http from '@ohos.net.http';
import { LogUtil } from '@pura/harmony-utils';

const TAG = '[UserApi]: ';

export class UserApi {
  /**
   * 获取用户资料 (基础版)
   * @param uid 用户ID
   * @throws Error 当网络请求失败或业务码不为0时抛出
   */
  public static async getUserProfile(uid: number): Promise<UserProfileData> {
    // 构造请求路径
    const path = `/_/user/${uid}/profile?user_summary=1`;

    // 直接调用 ApiClient，不包裹 try-catch，让底层错误（如 401、网络超时）冒泡给 ViewModel
    const response = await ApiClient.getInstance().request<BaseResponse<UserProfileData>>({
      path: path,
      method: http.RequestMethod.GET,
      includeAuthorization: true,
      includeCookie: true
    });

    // 检查 HTTP 状态码 和 业务 ErrorCode
    if (response.status === 200 && response.data.code === 0) {
      return response.data.data;
    } else {
      // 抛出具体错误供 VM 处理
      const errorMsg = response.data?.message || `Fetch profile failed, status: ${response.status}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  /**
   * 获取完整的用户个人资料
   * 包含摘要、详细信息(邮箱/签名等)以及最近访客
   * @param uid 用户ID，传 'me' 代表当前登录用户
   * @throws Error 当网络请求失败或业务码不为0时抛出
   */
  public static async getFullUserProfile(uid: number | 'me'): Promise<UserProfileData> {
    const idStr = uid === 'me' ? 'me' : uid.toString();
    const path = `/_/user/${idStr}/profile?user_summary=1&visitors=1`;

    LogUtil.info(TAG, `Fetching full profile for: ${idStr}`);

    const response = await ApiClient.getInstance().request<BaseResponse<UserProfileData>>({
      path: path,
      method: http.RequestMethod.GET,
      includeAuthorization: true,
      includeCookie: true
    });

    if (response.status === 200 && response.data.code === 0 && response.data.data) {
      return response.data.data;
    } else {
      const errorMsg = response.data?.message || `Fetch full profile failed, status: ${response.status}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }
}