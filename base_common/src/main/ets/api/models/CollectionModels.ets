export interface CollectionCreator {
  username: string; // 用户昵称
  uid: number; // 用户uid
}

export interface Collection {
  title: string; // 专辑名
  collection_nums: number; // 专辑主题数
  subscribe: number; // 专辑订阅数
  comment: number; // 专辑留言数
  creator: CollectionCreator; // 专辑创建用户
  description?: string; // 专辑描述（可能没有）
  lastUpdate: string; // 最后更新时间
}