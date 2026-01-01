import { ApiClient } from './ApiClient';
import {
  BaseResponse,
  FriendUser,
  InterestingUser,
  PaginationData,
  RecentVisitor,
  UserFriends,
  UserProfileData,
  UserSummary
} from './models/UserModels';
import http from '@ohos.net.http';
import { LogUtil } from '@pura/harmony-utils';
import { UserAvatarUtil } from '../utils/UserAvatarUtil';

const TAG = '[UserApi]: ';

interface LegacyResponse {
  rs: number; // 成功标记: 1 为成功, 0 为失败
  errcode: string; // 错误码
  head?: LegacyHead; // 响应头信息
  body?: Object; // 响应体
  pois?: Record<string, string>[];
}

interface LegacyHead {
  errInfo?: string; // 错误描述信息
  version?: string;
}

export class UserApi {
  /**
   * 获取用户资料 (基础版)
   * @param uid 用户ID
   * @throws Error 当网络请求失败或业务码不为0时抛出
   */
  public static async getUserProfile(uid: number): Promise<UserSummary> {
    // 构造请求路径
    const path = `/_/user/${uid}/profile?user_summary=1`;

    // 直接调用 ApiClient，不包裹 try-catch，让底层错误（如 401、网络超时）冒泡给 ViewModel
    const response = await ApiClient.getInstance().request<BaseResponse<UserSummary>>({
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
  public static async getFullUserProfile(uid: number | 'me', hideVisit: boolean = false): Promise<UserProfileData> {
    const idStr = uid === 'me' ? 'me' : uid.toString();
    const path = `/_/user/${idStr}/profile?user_summary=1&visitors=1${hideVisit ? '&additional=removevlog' : ''}`;

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

  /**
   * 获取用户好友
   * 包含摘要、详细信息(邮箱/签名等)以及最近访客
   * @param uid 用户ID，传 'me' 代表当前登录用户
   * @throws Error 当网络请求失败或业务码不为0时抛出
   */
  public static async getUserFriends(page: number = 1): Promise<UserFriends[]> {
    const path = `/_/user/me/friends?page=${page}&user_summary`;
    const userFriends: UserFriends[] = [];

    const response = await ApiClient.getInstance().request<BaseResponse<PaginationData<UserFriends>>>({
      path: path,
      method: http.RequestMethod.GET,
      includeAuthorization: true,
      includeCookie: true
    });

    if (response.status === 200 && response.data.code === 0 && response.data.data) {
      const tasks = response.data.data.rows.map(async (friend: FriendUser) => {
        // 在这里进行详情获取
        let friendProfile: UserProfileData = await UserApi.getFullUserProfile(friend.uid, true);

        // 组装数据并返回
        let friendData: UserFriends = {
          uid: friend.uid,
          username: friend.username,
          signature: friendProfile.signature === "" ? $r('app.string.UserApi_no_signature') : friendProfile.signature!,
          avatar: UserAvatarUtil.getAvatarUrl(friend.uid),
          level: friendProfile.user_summary?.group_title!,
          last_visit: friendProfile.last_visit
        };
        return friendData;
      });

      const userFriends = await Promise.all(tasks);
      return userFriends;
    } else {
      const errorMsg = response.data?.message || `Fetch full profile failed, status: ${response.status}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  /**
   * 获取用户访客
   * 包含摘要、详细信息(邮箱/签名等)以及最近访客
   * @param uid 用户ID，传 'me' 代表当前登录用户
   * @throws Error 当网络请求失败或业务码不为0时抛出
   */
  public static async getUserVisitors(): Promise<RecentVisitor[]> {
    const path = `/_/user/me/profile?visitors=1`;
    const recentVisitors: RecentVisitor[] = [];

    const response = await ApiClient.getInstance().request<BaseResponse<UserProfileData>>({
      path: path,
      method: http.RequestMethod.GET,
      includeAuthorization: true,
      includeCookie: true
    });

    if (response.status === 200 && response.data.code === 0 && response.data.data &&
    response.data.data.recent_visitors) {
      response.data.data.recent_visitors.forEach((visitor: RecentVisitor) => {
        let visitor_map: RecentVisitor = {
          uid: visitor.uid,
          username: visitor.username,
          avatar: UserAvatarUtil.getAvatarUrl(visitor.uid),
          dateline: visitor.dateline
        }

        recentVisitors.push(visitor_map);
      })

      return recentVisitors;
    } else {
      const errorMsg = response.data?.message || `Fetch full profile failed, status: ${response.status}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  /**
   * 修改个性签名 (使用旧版 API)
   * @param signature 新的签名内容
   */
  public static async editSignature(signature: string): Promise<boolean> {
    // [修复] 传入泛型 LegacyResponse，明确告知编译器返回数据的结构
    const result = await ApiClient.getInstance().requestLegacy<LegacyResponse>('user', 'updateuserinfo', {
      'type': 'info',
      'sign': signature
    });

    // [修复] 使用点符号访问属性，符合 ArkTS 规范
    if (result.data.rs === 1) {
      const errorMsg = `Fetch full profile failed, status: ${result.data.errcode}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    } else {
      // 安全访问可选属性
      const errInfo = result.data.head?.errInfo || 'Unknown error';
      LogUtil.warn(TAG, `Update signature failed: ${result.data.errcode} - ${errInfo}`);
      return false;
    }
  }

  // 获取感兴趣的人
  public static async getInterestedUser(): Promise<InterestingUser[]> {
    const interestedUser: InterestingUser[] = [];

    const result =
      await ApiClient.getInstance().requestLegacy<LegacyResponse>('square', 'surrounding', {
        'longitude': '103.93',
        'latitude': '30.74',
        'poi': 'user',
        'page': 1,
        'pageSize': '15'
      });

    if (result.data.rs === 1) {
      result.data.pois?.forEach((poi: Record<string, Object>) => {
        interestedUser.push({
          uid: poi.uid as number,
          username: poi.nickname as string,
          avatar: poi.icon as string,
          isFriend: poi.is_friend as number === 0 ? false : true
        })
      });

      return interestedUser;
    } else {
      const errorMsg = `Fetch full profile failed, status: ${result.data.errcode}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }
}