import { ForumDetailResponse } from './ForumModels';

/**
 * 淘专辑排序方式
 */
export enum CollectionSortOrder {
  /**
   * 按创建时间排序 (默认)
   * 对应参数: &op=all
   */
  DATE = '',

  /**
   * 按主题数排序
   * 对应参数: &op=all&order=threadnum
   */
  THREAD_NUM = 'threadnum',

  /**
   * 按评论数排序
   * 对应参数: &op=all&order=commentnum
   */
  COMMENT_NUM = 'commentnum',

  /**
   * 按订阅数排序
   * 对应参数: &op=all&order=follownum
   */
  FOLLOW_NUM = 'follownum'
}

export interface CollectionUser {
  username: string; // 用户昵称
  uid: number; // 用户uid
}

export interface Collection {
  ctid: number; // 专辑ID
  title: string; // 专辑名
  collection_nums: number; // 专辑主题数
  subscribe: number; // 专辑订阅数
  comment: number; // 专辑留言数
  creator: CollectionUser; // 专辑创建用户
  description?: string; // 专辑描述（可能没有）
  lastUpdate?: string; // 最后更新时间
  tags?: string[]; // TAG
}

export interface CollectionDetail {
  ctid: number; // 专辑ID
  rate?: number; // 评分（可能没有）
  isFollow?: boolean; // 是否已订阅 (0:未订阅, 1:已订阅)
  formhash?: string; // 用于订阅或取消订阅的校验码
  newSubsUser?: CollectionUser[]; // 最新订阅用户（可能没有）
  userMoreCollections?: Collection[]; // 用户更多的淘专辑
  ties?: ForumDetailResponse[]; // 所对应帖子的详情信息
}