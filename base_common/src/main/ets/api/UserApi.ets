import { ApiClient } from './ApiClient';
import {
  BaseResponse,
  FriendUser,
  InterestingUser,
  Medal,
  PaginationData,
  RecentVisitor,
  ThreadAuthorInfo,
  UserFavorite,
  UserFriends,
  UserProfileData,
  UserReply,
  UserSummary,
  UserThread
} from './models/UserModels';
import http from '@ohos.net.http';
import { LogUtil } from '@pura/harmony-utils';
import { UserAvatarUtil } from '../utils/UserAvatarUtil';
import { LegacyResponse } from './ApiClient';
import { ForumApi } from './ForumApi';

const TAG = '[UserApi]: ';

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
   * @param page 页码
   * @param uid 用户ID，传 'me' 代表当前登录用户，默认为 'me'
   * @throws Error 当网络请求失败或业务码不为0时抛出
   */
  public static async getUserFriends(page: number = 1, uid: number | 'me' = 'me'): Promise<UserFriends[]> {
    // 修改：支持动态传入 uid
    const idStr = uid === 'me' ? 'me' : uid.toString();
    const path = `/_/user/${idStr}/friends?page=${page}&user_summary`;

    const response = await ApiClient.getInstance().request<BaseResponse<PaginationData<FriendUser>>>({
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
   * 获取用户访客 (已修改支持指定 UID)
   * 包含摘要、详细信息(邮箱/签名等)以及最近访客
   * @param uid 用户ID，传 'me' 代表当前登录用户，默认为 'me'
   */
  public static async getUserVisitors(uid: number | 'me' = 'me'): Promise<RecentVisitor[]> {
    // 修改点：支持动态构造 URL
    const idStr = uid === 'me' ? 'me' : uid.toString();
    const path = `/_/user/${idStr}/profile?visitors=1`;
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
    const result = await ApiClient.getInstance().requestLegacy<LegacyResponse>('user', 'updateuserinfo', {
      'type': 'info',
      'sign': signature
    });

    // 修复点：rs === 1 表示成功，返回 true
    if (result.data.rs === 1) {
      return true;
    } else {
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

  // 删除好友
  public static async deleteFriend(uid: number): Promise<boolean> {
    const path = `/_/user/friend/${uid}`;

    const response = await ApiClient.getInstance().request<BaseResponse<UserProfileData>>({
      path: path,
      method: http.RequestMethod.DELETE,
      includeAuthorization: true,
      includeCookie: true
    });

    if (response.status === 200 && response.data.code === 0 && response.data.data) {
      return true;
    } else {
      const errorMsg = response.data?.message || `Fetch full profile failed, status: ${response.status}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  // 获取勋章
  public static async getMedals(): Promise<Medal[]> {
    const path = `/_/system/settings/medals`;

    const response = await ApiClient.getInstance().request<BaseResponse<Record<string, Record<string, Object>>>>({
      path: path,
      method: http.RequestMethod.GET,
      includeAuthorization: true,
      includeCookie: true
    });

    if (response.status === 200 && response.data.code === 0 && response.data.data) {
      return response.data.data.medals.value as Medal[];
    } else {
      const errorMsg = response.data?.message || `Fetch full profile failed, status: ${response.status}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  /**
   * 获取用户发布的主题帖
   */
  public static async getUserThreads(page: number, uid: number | 'me' = 'me'): Promise<PaginationData<UserThread>> {
    const idStr = uid === 'me' ? 'me' : uid.toString();
    const path = `/_/user/${idStr}/threads?page=${page}&user_summary=0`;

    // 这里的泛型 <BaseResponse<PaginationData<UserThread>>> 会传递给 request
    const response = await ApiClient.getInstance().request<BaseResponse<PaginationData<UserThread>>>({
      path: path,
      method: http.RequestMethod.GET,
      includeAuthorization: true,
      includeCookie: true
    });

    if (response.status === 200 && response.data.code === 0) {
      return response.data.data;
    } else {
      throw new Error(response.data?.message || 'Fetch user threads failed');
    }
  }

  /**
   * 获取用户发布的回复
   */
  public static async getUserReplies(page: number, uid: number | 'me' = 'me'): Promise<PaginationData<UserReply>> {
    const idStr = uid === 'me' ? 'me' : uid.toString();
    const path = `/_/user/${idStr}/replies?page=${page}&user_summary=0`;

    const response = await ApiClient.getInstance().request<BaseResponse<PaginationData<UserReply>>>({
      path: path,
      method: http.RequestMethod.GET,
      includeAuthorization: true,
      includeCookie: true
    });

    if (response.status === 200 && response.data.code === 0) {
      const data = response.data.data;

      try {
        const threadIds = new Set<number>();
        data.rows.forEach(reply => {
          if (reply.thread_id) {
            threadIds.add(reply.thread_id);
          }
        });

        const fetchTasks = Array.from(threadIds).map(async (tid): Promise<ThreadAuthorInfo | null> => {
          try {
            const detail = await ForumApi.getForumDetail(tid, 1);
            return {
              author: detail.thread.author,
              author_id: detail.thread.author_id
            };
          } catch (e) {
            LogUtil.warn(TAG, `Failed to fetch thread info for tid:${tid}, error:${JSON.stringify(e)}`);
            return null;
          }
        });

        const threadInfos = await Promise.all(fetchTasks);

        const threadIdsArray = Array.from(threadIds);

        const threadInfoMap = new Map<number, ThreadAuthorInfo>();

        threadInfos.forEach((info, index) => {
          if (info) {
            const tid = threadIdsArray[index];
            threadInfoMap.set(tid, info);
          }
        });

        data.rows.forEach(reply => {
          const info = threadInfoMap.get(reply.thread_id);
          if (info) {
            reply.author = info.author;
            reply.author_id = info.author_id;
          } else {
            reply.author = reply.author || '主题作者';
            reply.author_id = reply.author_id || 0;
          }
        });

      } catch (e) {
        LogUtil.warn(TAG, 'Error enriching replies with thread info: ' + JSON.stringify(e));
      }
      return data;
    } else {
      throw new Error(response.data?.message || 'Fetch user replies failed');
    }
  }

  /**
   * 获取用户收藏 (仅限自己)
   */
  public static async getUserFavorites(page: number): Promise<PaginationData<UserFavorite>> {
    const path = `/_/user/me/favorites?page=${page}&collections=1&user_summary=0`;

    const response = await ApiClient.getInstance().request<BaseResponse<PaginationData<UserFavorite>>>({
      path: path,
      method: http.RequestMethod.GET,
      includeAuthorization: true,
      includeCookie: true
    });

    if (response.status === 200 && response.data.code === 0) {
      return response.data.data;
    } else {
      throw new Error(response.data?.message || 'Fetch user favorites failed');
    }
  }
}