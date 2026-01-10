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

export interface CollectionFollowResult {
  success: boolean;
  message: string;
}

/**
 * 用户信息模型
 */
@ObservedV2
export class CollectionUser {
  @Trace username: string = '';
  @Trace uid: number = 0;

  constructor(data?: Partial<CollectionUser>) {
    if (data) {
      this.username = data.username ?? '';
      this.uid = data.uid ?? 0;
    }
  }
}

/**
 * 淘专辑模型
 */
@ObservedV2
export class Collection {
  @Trace ctid: number = 0;
  @Trace title: string = '';
  @Trace collection_nums: number = 0;
  @Trace subscribe: number = 0;
  @Trace comment: number = 0;
  @Trace creator: CollectionUser = new CollectionUser();
  @Trace description: string = '';
  @Trace lastUpdate: string = '';
  @Trace tags: string[] = [];
}

@ObservedV2
export class CollectionDetail {
  @Trace ctid: number = 0;
  @Trace rate: number = 0;
  @Trace isFollow?: boolean;
  @Trace formhash: string = '';
  @Trace newSubsUser: CollectionUser[] = [];
  @Trace userMoreCollections: Collection[] = [];
  @Trace ties: ForumDetailResponse[] = [];
}