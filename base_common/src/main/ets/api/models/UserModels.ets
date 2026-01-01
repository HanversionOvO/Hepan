/**
 * 用户相关数据模型定义
 * 对应文档: docs/api_new/doc/用户.md
 */

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
  rows: FriendUser[];
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
export interface UserSummary {
  uid: number;
  username: string;
  group_id: number;
  level_id: number;
  group_title: string;
  group_subtitle?: string;
  group_icon?: string;
  credits: number;
  ext_credits: ExtCredits;
  medals?: number[]; // 勋章ID列表
  friends: number;
  threads: number;
  replies: number;
  digests: number;
  views: number;
}

/**
 * 最近访客
 */
export interface RecentVisitor {
  uid: number;
  avatar: string;
  username: string;
  dateline: number;
}

/**
 * 完整的用户资料数据
 * 对应接口: /_/user/{uid}/profile 的 data 字段
 */
export interface UserProfileData {
  // 摘要信息 (当 user_summary=1 时返回)
  user_summary?: UserSummary;

  // 最近访客 (当 visitors=1 时返回)
  recent_visitors?: RecentVisitor[];

  // 详细个人信息
  email?: string; // 敏感信息，仅自己可见
  register_time?: number; // 注册时间戳
  introduction?: string; // 个人介绍
  custom_title?: string; // 自定义头衔
  signature?: string; // 签名
  signature_format?: string; // 签名格式 (如 'html')
  online_time: number; // 在线时间 (小时或秒，视具体实现，通常为小时)
  last_visit: number; // 最后访问时间戳
  last_activity?: number; // 最后活动时间戳
  last_post?: number; // 最后发帖时间戳
  register_ip?: string; // 注册IP (敏感信息)
  last_ip?: string; // 最后IP (敏感信息)
}

// 勋章信息
export interface Medal {
  id: number;
  name: string;
  image_path: string;
  type: number;
  display_order: number;
  description: string;
  expiration_days: number;
  ext_credit: string;
  price: number;
}


// ==========================================
// 好友 (Friends) 相关
// ==========================================

/**
 * 简略的最新帖子信息 (用于好友列表)
 */
export interface SimpleThreadInfo {
  tid: number;
  subject: string;
  dateline: number;
}

/**
 * 好友列表项
 * 对应接口: /_/user/me/friends 的 rows 字段
 * 结构类似于 UserSummary，但包含 latest_thread 等特定字段
 */
export interface FriendUser {
  uid: number;
  username: string;
  group_id: number;
  level_id: number;
  group_title: string;
  group_subtitle?: string;
  group_icon?: string;
  credits: number;
  ext_credits: ExtCredits;
  friends: number;
  replies: number;
  threads: number;
  digests: number;

  // 好友列表特有字段
  latest_thread?: SimpleThreadInfo;
}

export interface UserFriends {
  uid: number;
  username: string;
  signature: ResourceStr;
  avatar: string;
  level: string;
  last_visit: number;
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
export interface InterestingUser {
  uid: number;
  username: string;
  avatar: string;
  isFriend: boolean;
}