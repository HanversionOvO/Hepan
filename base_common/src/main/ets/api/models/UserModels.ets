/**
 * ??????????
 * ????: docs/api_new/doc/??.md
 */

import { ForumTieSummary } from './ForumModels';

// ==========================================
// ??????
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
  hidden?: boolean; // ????????????????????
}

// ==========================================
// ??????
// ==========================================

// ?????? (?: {"??": 7, "??": 9820})
export type ExtCredits = Record<string, number>;

// ==========================================
// ?????? (Profile) ??
// ==========================================

/**
 * ????????
 * ????: /_/user/{uid}/profile (user_summary??)
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
  medals?: number[]; // ??ID??
  friends: number;
  threads: number;
  replies: number;
  digests: number;
  views: number;
}

/**
 * ????
 */
export interface RecentVisitor {
  uid: number;
  avatar: string;
  username: string;
  dateline: number;
}

/**
 * ?????????
 * ????: /_/user/{uid}/profile ? data ??
 */
export interface UserProfileData {
  // ???? (? user_summary=1 ???)
  user_summary?: UserSummary;
  // ???? (? visitors=1 ???)
  recent_visitors?: RecentVisitor[];
  // ??????
  email?: string; // ??????????
  register_time?: number; // ?????
  introduction?: string; // ????
  custom_title?: string; // ?????
  signature?: string; // ??
  signature_format?: string; // ???? (? 'html')
  online_time: number; // ???? (????????????????)
  last_visit: number; // ???????
  last_activity?: number; // ???????
  last_post?: number; // ???????
  register_ip?: string; // ??IP (????)
  last_ip?: string; // ??IP (????)
}

export function createEmptyUserProfileData(): UserProfileData {
  return {
    online_time: 0,
    last_visit: 0
  };
}

// ????
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

export function createEmptyMedal(): Medal {
  return {
    id: 0,
    name: '',
    image_path: '',
    type: 0,
    display_order: 0,
    description: '',
    expiration_days: 0,
    ext_credit: '',
    price: 0
  };
}

export interface MedalListContainer {
  value: Medal[];
}

export interface MedalListResponse {
  medals: MedalListContainer;
}

// ==========================================
// ?? (Friends) ??
// ==========================================

/**
 * ????????? (??????)
 */
export interface SimpleThreadInfo {
  tid: number;
  subject: string;
  dateline: number;
}

/**
 * ?????
 * ????: /_/user/me/friends ? rows ??
 * ????? UserSummary???? latest_thread ?????
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
  latest_thread?: SimpleThreadInfo;
  last_visit?: number;
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
 * ???????
 * ????: PUT /_/user/friend
 */
export interface AddFriendRequest {
  uid: number;
  message: string;
}

/**
 * ???????
 */
export interface AddFriendResult {
  friend_status: string; // e.g., 'requested'
}

// ?????
export interface InterestingUser {
  uid: number;
  username: string;
  avatar: string;
  isFriend: boolean;
}

export interface InterestedUserPoi {
  uid: number;
  nickname: string;
  icon: string;
  is_friend: number;
}

export type UserThread = ForumTieSummary;

export interface ThreadAuthorInfo {
  author: string;
  author_id: number;
}

export interface UserReply {
  forum_id: number;
  thread_id: number;
  post_id: number;
  subject: string;
  summary: string;
  dateline: number;
  last_post: number;
  last_poster: string;
  views: number;
  replies: number;
  forum_name: string;
  author?: string;
  author_id?: number;
}

export interface UserFavorite {
  favorite_id: number;
  target_id: number;
  target_type: string;
  title: string;
  dateline: number;
  thread_details: ForumTieSummary;
}
