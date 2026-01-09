/**
 * 用户相关数据模型定义
 * 对应文档: docs/api_new/doc/用户.md
 */

import { ForumTieSummary } from './ForumModels';

// ==========================================
// 通用响应结构
// ==========================================

export interface BaseResponse<T> {
  code: number;
  message: string;
  data: T;
}

export interface PaginationData<T> {
  total: number;
  page_size: number;
  page: number;
  rows: T[];
  hidden?: boolean; // 部分接口（如好友、留言板）可能包含此字段
}

// ==========================================
// 基础数据类型
// ==========================================

// 扩展积分类型 (如: {"威望": 7, "水滴": 9820})
export type ExtCredits = Record<string, number>;

// ==========================================
// 用户个人资料 (Profile) 相关
// ==========================================

/**
 * 用户基本摘要信息
 * 对应接口: /_/user/{uid}/profile (user_summary字段)
 */
@ObservedV2
export class UserSummary {
  @Trace uid: number = 0;
  @Trace username: string = "";
  @Trace group_id: number = 0;
  @Trace level_id: number = 0;
  @Trace group_title: string = "";
  @Trace group_subtitle?: string;
  @Trace group_icon?: string;
  @Trace credits: number = 0;
  @Trace ext_credits: ExtCredits = {};
  @Trace medals?: number[]; // 勋章ID列表
  @Trace friends: number = 0;
  @Trace threads: number = 0;
  @Trace replies: number = 0;
  @Trace digests: number = 0;
  @Trace views: number = 0;
}

/**
 * 最近访客
 */
@ObservedV2
export class RecentVisitor {
  @Trace uid: number = 0;
  @Trace avatar: string = "";
  @Trace username: string = "";
  @Trace dateline: number = 0;
}

/**
 * 完整的用户资料数据
 * 对应接口: /_/user/{uid}/profile 的 data 字段
 */
@ObservedV2
export class UserProfileData {
  // 摘要信息 (当 user_summary=1 时返回)
  @Trace user_summary?: UserSummary;
  // 最近访客 (当 visitors=1 时返回)
  @Trace recent_visitors?: RecentVisitor[];
  // 详细个人信息
  @Trace email?: string; // 敏感信息，仅自己可见
  @Trace register_time?: number; // 注册时间戳
  @Trace introduction?: string; // 个人介绍
  @Trace custom_title?: string; // 自定义头衔
  @Trace signature?: string; // 签名
  @Trace signature_format?: string; // 签名格式 (如 'html')
  @Trace online_time: number = 0; // 在线时间 (小时或秒，视具体实现，通常为小时)
  @Trace last_visit: number = 0; // 最后访问时间戳
  @Trace last_activity?: number; // 最后活动时间戳
  @Trace last_post?: number; // 最后发帖时间戳
  @Trace register_ip?: string; // 注册IP (敏感信息)
  @Trace last_ip?: string; // 最后IP (敏感信息)
}

// 勋章信息
@ObservedV2
export class Medal {
  @Trace id: number = 0;
  @Trace name: string = "";
  @Trace image_path: string = "";
  @Trace type: number = 0;
  @Trace display_order: number = 0;
  @Trace description: string = "";
  @Trace expiration_days: number = 0;
  @Trace ext_credit: string = "";
  @Trace price: number = 0;
}


// ==========================================
// 好友 (Friends) 相关
// ==========================================

/**
 * 简略的最新帖子信息 (用于好友列表)
 */
@ObservedV2
export class SimpleThreadInfo {
  @Trace tid: number = 0;
  @Trace subject: string = "";
  @Trace dateline: number = 0;
}

/**
 * 好友列表项
 * 对应接口: /_/user/me/friends 的 rows 字段
 * 结构类似于 UserSummary，但包含 latest_thread 等特定字段
 */
@ObservedV2
export class FriendUser {
  @Trace uid: number = 0;
  @Trace username: string = "";
  @Trace group_id: number = 0;
  @Trace level_id: number = 0;
  @Trace group_title: string = "";
  @Trace group_subtitle?: string = "";
  @Trace group_icon?: string = "";
  @Trace credits: number = 0;
  @Trace ext_credits: ExtCredits = {};
  @Trace friends: number = 0;
  @Trace replies: number = 0;
  @Trace threads: number = 0;
  @Trace digests: number = 0;
  // 好友列表特有字段
  @Trace latest_thread?: SimpleThreadInfo;
}

@ObservedV2
export class UserFriends {
  @Trace uid: number = 0;
  @Trace username: string = "";
  @Trace signature: ResourceStr = "";
  @Trace avatar: string = "";
  @Trace level: string = "";
  @Trace last_visit: number = 0;
}

/**
 * 加好友请求负载
 * 对应接口: PUT /_/user/friend
 */
export interface AddFriendRequest {
  uid: number;
  message: string;
}

/**
 * 加好友响应数据
 */
export interface AddFriendResult {
  friend_status: string; // e.g., 'requested'
}

// 感兴趣的人
@ObservedV2
export class InterestingUser {
  @Trace uid: number = 0;
  @Trace username: string = "";
  @Trace avatar: string = "";
  @Trace isFriend: boolean = false;
}

@ObservedV2
export class UserThread extends ForumTieSummary {
  @Trace forum_name?: string;
}

@ObservedV2
export class ThreadAuthorInfo {
  @Trace author: string = "";
  @Trace author_id: number = 0;
}

@ObservedV2
export class UserReply {
  @Trace forum_id: number = 0;
  @Trace thread_id: number = 0;
  @Trace post_id: number = 0;
  @Trace subject: string = "";
  @Trace summary: string = "";
  @Trace dateline: number = 0;
  @Trace last_post: number = 0;
  @Trace last_poster: string = "";
  @Trace views: number = 0;
  @Trace replies: number = 0;
  @Trace forum_name: string = "";
  @Trace author?: string;
  @Trace author_id?: number;
}

@ObservedV2
export class UserFavorite {
  @Trace favorite_id: number = 0;
  @Trace target_id: number = 0;
  @Trace target_type: string = "";
  @Trace title: string = "";
  @Trace dateline: number = 0;
  @Trace thread_details: ForumTieSummary = new ForumTieSummary();
}