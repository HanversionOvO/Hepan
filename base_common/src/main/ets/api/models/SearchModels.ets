import { ForumTieSummary } from './ForumModels';

/**
 * 搜索结果中的用户信息
 * 对应接口: /_/search/summary 和 /_/search/users 中的 users/rows 字段
 */
@ObservedV2
export class SearchUser {
  @Trace uid: number = 0;
  @Trace username: string = "";
  @Trace group_id: number = 0;
  @Trace level_id: number = 0;
  @Trace group_title: string = "";
  @Trace group_subtitle: string = "";
  @Trace group_icon: string = "";
}

/**
 * 搜索预览/摘要响应数据
 * 对应接口: /_/search/summary 的 data 字段
 */
@ObservedV2
export class SearchSummaryData {
  // 预览的帖子列表
  @Trace threads: ForumTieSummary[] = [];
  // 匹配的帖子总数
  @Trace thread_count: number = 0;
  // 预览的用户列表
  @Trace users: SearchUser[] = [];
  // 匹配的用户总数
  @Trace user_count: number = 0;
  // 精确匹配的帖子（当搜索词为有效 TID 时出现）
  @Trace tid_match?: ForumTieSummary;
  // 精确匹配的用户（当搜索词为有效 UID 时出现）
  @Trace uid_match?: SearchUser;
}