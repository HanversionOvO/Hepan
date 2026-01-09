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
  @Trace creator: CollectionUser = new CollectionUser(); // 嵌套对象初始化
  @Trace description: string = '';
  @Trace lastUpdate: string = '';
  @Trace tags: string[] = [];

  constructor(data?: Partial<Collection>) {
    if (data) {
      this.ctid = data.ctid ?? 0;
      this.title = data.title ?? '';
      this.collection_nums = data.collection_nums ?? 0;
      this.subscribe = data.subscribe ?? 0;
      this.comment = data.comment ?? 0;
      // 关键：嵌套对象必须实例化，否则无法监听内部变化
      this.creator = data.creator ? new CollectionUser(data.creator) : new CollectionUser();
      this.description = data.description ?? '';
      this.lastUpdate = data.lastUpdate ?? '';
      this.tags = data.tags ?? [];
    }
  }
}

@ObservedV2
export class CollectionDetail {
  @Trace ctid: number = 0;
  @Trace rate: number = 0;
  @Trace isFollow: boolean = false;
  @Trace formhash: string = '';
  @Trace newSubsUser: CollectionUser[] = [];
  @Trace userMoreCollections: Collection[] = [];
  @Trace ties: ForumDetailResponse[] = [];

  constructor(data?: Partial<CollectionDetail>) {
    if (data) {
      this.ctid = data.ctid ?? 0;
      this.rate = data.rate ?? 0;
      this.isFollow = data.isFollow === true;
      this.formhash = data.formhash ?? '';

      if (data.newSubsUser && Array.isArray(data.newSubsUser)) {
        this.newSubsUser = data.newSubsUser.map((item: CollectionUser) => new CollectionUser(item));
      }

      if (data.userMoreCollections && Array.isArray(data.userMoreCollections)) {
        this.userMoreCollections = data.userMoreCollections.map((item: Collection) => new Collection(item));
      }

      this.ties = data.ties ?? [];
    }
  }
}