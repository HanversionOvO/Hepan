import { ApiClient, ApiResponse, LegacyResponse } from './ApiClient';
import {
  BaseResponse,
  FriendUser,
  InterestingUser,
  InterestedUserPoi,
  Medal,
  MedalListResponse,
  PaginationData,
  RecentVisitor,
  ThreadAuthorInfo,
  UserFavoritesResponse,
  UserFriends,
  UserProfileData,
  UserReply,
  UserSummary,
  UserThread
} from './models/UserModels';
import http from '@ohos.net.http';
import { LogUtil } from '@pura/harmony-utils';
import { UserAvatarUtil } from '../utils/UserAvatarUtil';
import { ForumApi } from './ForumApi';

const TAG = '[UserApi]: ';

export class UserApi {
  private static readonly threadAuthorCache: Map<number, ThreadAuthorInfo> = new Map();

  private static extractData<T>(response: ApiResponse<BaseResponse<T>>, fallbackMessage: string): T {
    if (response.status === 200 && response.data.code === 0 &&
      response.data.data !== undefined && response.data.data !== null) {
      return response.data.data;
    }
    const errorMsg = response.data?.message || `${fallbackMessage}, status: ${response.status}`;
    LogUtil.warn(TAG, errorMsg);
    throw new Error(errorMsg);
  }

  private static normalizeUserSummary(summary: UserSummary): UserSummary {
    if (!summary.ext_credits) {
      summary.ext_credits = {};
    }
    if (!summary.medals) {
      summary.medals = [];
    }
    return summary;
  }

  private static normalizeUserProfile(profile: UserProfileData): UserProfileData {
    if (profile.online_time === undefined) {
      profile.online_time = 0;
    }
    if (profile.last_visit === undefined) {
      profile.last_visit = 0;
    }
    if (profile.user_summary) {
      profile.user_summary = UserApi.normalizeUserSummary(profile.user_summary);
    }
    if (!profile.recent_visitors) {
      profile.recent_visitors = [];
    }
    return profile;
  }

  private static buildUserFriends(friend: FriendUser, profile?: UserProfileData): UserFriends {
    const signature = profile?.signature || '';
    const resolvedSignature = signature === '' ? $r('app.string.UserApi_no_signature') : signature;
    return {
      uid: friend.uid,
      username: friend.username,
      signature: resolvedSignature,
      avatar: UserAvatarUtil.getAvatarUrl(friend.uid),
      level: profile?.user_summary?.group_title || friend.group_title || '',
      last_visit: profile?.last_visit ?? friend.last_visit ?? 0
    };
  }

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
    const summary = UserApi.extractData(response, 'Fetch profile failed');
    return UserApi.normalizeUserSummary(summary);
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
    const profile = UserApi.extractData(response, 'Fetch full profile failed');
    return UserApi.normalizeUserProfile(profile);
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
    const data = UserApi.extractData(response, 'Fetch friends failed');
    const rows = data.rows;

    const profileTasks = rows.map((friend) => UserApi.getFullUserProfile(friend.uid, true));
    const profiles = await Promise.allSettled(profileTasks);

    return rows.map((friend, index) => {
      const profileResult = profiles[index];
      if (profileResult.status === 'fulfilled') {
        return UserApi.buildUserFriends(friend, profileResult.value);
      }
      LogUtil.warn(TAG, `Failed to load profile for uid: ${friend.uid}`);
      return UserApi.buildUserFriends(friend);
    });
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
    const response = await ApiClient.getInstance().request<BaseResponse<UserProfileData>>({
      path: path,
      method: http.RequestMethod.GET,
      includeAuthorization: true,
      includeCookie: true
    });
    const data = UserApi.extractData(response, 'Fetch visitors failed');
    const visitors = data.recent_visitors || [];
    return visitors.map((visitor): RecentVisitor => {
      const mapped: RecentVisitor = {
        uid: visitor.uid,
        username: visitor.username,
        avatar: UserAvatarUtil.getAvatarUrl(visitor.uid),
        dateline: visitor.dateline
      };
      return mapped;
    });
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
      const pois = result.data.pois;
      if (!pois || !Array.isArray(pois)) {
        return interestedUser;
      }
      pois.forEach((poi) => {
        const mappedPoi: InterestedUserPoi = {
          uid: Number(poi['uid'] || 0),
          nickname: poi['nickname'] || '',
          icon: poi['icon'] || '',
          is_friend: Number(poi['is_friend'] || 0)
        };
        const item: InterestingUser = {
          uid: mappedPoi.uid,
          username: mappedPoi.nickname,
          avatar: mappedPoi.icon,
          isFriend: mappedPoi.is_friend !== 0
        };
        interestedUser.push(item);
      });
      return interestedUser;
    }
    const errorMsg = `Fetch interested user failed, status: ${result.data.errcode}`;
    LogUtil.warn(TAG, errorMsg);
    throw new Error(errorMsg);
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

    if (response.status === 200 && response.data.code === 0) {
      return true;
    } else {
      const errorMsg = response.data?.message || `Delete friend failed, status: ${response.status}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  // 获取勋章
  public static async getMedals(): Promise<Medal[]> {
    const path = `/_/system/settings/medals`;

    const response = await ApiClient.getInstance().request<BaseResponse<MedalListResponse>>({
      path: path,
      method: http.RequestMethod.GET,
      includeAuthorization: true,
      includeCookie: true
    });
    const data = UserApi.extractData(response, 'Fetch medals failed');
    return data.medals?.value || [];
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

    return UserApi.extractData(response, 'Fetch user threads failed');
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

    const data = UserApi.extractData(response, 'Fetch user replies failed');

    if (!data.rows || data.rows.length === 0) {
      return data;
    }

    try {
      const threadIds = new Set<number>();
      data.rows.forEach(reply => {
        if (reply.thread_id) {
          threadIds.add(reply.thread_id);
        }
      });

      const missingIds: number[] = [];
      threadIds.forEach((tid) => {
        if (!UserApi.threadAuthorCache.has(tid)) {
          missingIds.push(tid);
        }
      });

      const fetchTasks = missingIds.map(async (tid): Promise<ThreadAuthorInfo | null> => {
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
      threadInfos.forEach((info, index) => {
        if (info) {
          UserApi.threadAuthorCache.set(missingIds[index], info);
        }
      });

      data.rows.forEach(reply => {
        const info = UserApi.threadAuthorCache.get(reply.thread_id);
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
  }

  /**
   * 获取用户收藏 (仅限自己)
   */
  public static async getUserFavorites(page: number, collections: number = 0): Promise<UserFavoritesResponse> {
    const path = `/_/user/me/favorites?page=${page}&collections=${collections}&user_summary=0`;

    const response = await ApiClient.getInstance().request<BaseResponse<UserFavoritesResponse>>({
      path: path,
      method: http.RequestMethod.GET,
      includeAuthorization: true,
      includeCookie: true
    });

    return UserApi.extractData(response, 'Fetch user favorites failed');
  }
}
