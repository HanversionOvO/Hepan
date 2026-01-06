import { LegacyResponse } from './ApiModels';

// 1. 新增：定义纯数据接口，用于参数传递和类型检查
export interface RecentMessageData {
  plid?: number;
  pmid?: number;
  lastUserId?: number;
  lastUserName?: string;
  lastSummary?: string;
  lastDateline?: number;
  toUserId?: number;
  toUserAvatar?: string;
  toUserName?: string;
  toUserIsBlack?: string;
  isNew?: string;
}

// 2. 修改：RecentMessage 类使用该接口
@ObservedV2
export class RecentMessage {
  @Trace plid: number = 0;
  @Trace pmid: number = 0;
  @Trace lastUserId: number = 0;
  @Trace lastUserName: string = '';
  @Trace lastSummary: string = '';
  @Trace lastDateline: number = 0;
  @Trace toUserId: number = 0;
  @Trace toUserAvatar: string = '';
  @Trace toUserName: string = '';
  @Trace toUserIsBlack: string = '0';
  @Trace isNew: string = '0';

  // 构造函数接收接口类型
  constructor(data?: RecentMessageData) {
    if (data) {
      this.plid = data.plid ?? 0;
      this.pmid = data.pmid ?? 0;
      this.lastUserId = data.lastUserId ?? 0;
      this.lastUserName = data.lastUserName ?? '';
      this.lastSummary = data.lastSummary ?? '';
      this.lastDateline = data.lastDateline ?? 0;
      this.toUserId = data.toUserId ?? 0;
      this.toUserAvatar = data.toUserAvatar ?? '';
      this.toUserName = data.toUserName ?? '';
      this.toUserIsBlack = data.toUserIsBlack ?? '0';
      this.isNew = data.isNew ?? '0';
    }
  }
}

// ... 保持其他接口 (NewChat, MessageSummary 等) 不变
export interface PostSummary {
  reply: number;
  comment: number;
  at: number;
  rate: number;
  other: number;
}

export interface SystemSummary {
  friend: number;
  space: number;
  task: number;
  report: number;
  system: number;
  admin: number;
  app: number;
}

export interface NewMessagesSummary {
  chat: number;
  posts: PostSummary;
  system: SystemSummary;
}

export interface NewChat {
  last_author_id: number;
  last_author: string;
  last_summary: string;
  to_uid: number;
  to_username: string;
  conversation_id: string;
  unread: boolean;
  message_count: number;
  last_update: number;
  last_dateline: number;
  author_id: number;
  type: string;
  subject: string;
  member_count: number;
  create_time: number;
}

export interface MessageSummary {
  new_messages: NewMessagesSummary;
  new_chats: NewChat[];
}

export interface AnPNotification {
  board_name: string;
  board_id: number;
  topic_id: number;
  topic_subject: string;
  topic_content?: string;
  topic_url?: string;
  reply_content: string;
  reply_url: string;
  reply_remind_id?: number;
  reply_nick_name: string;
  user_id: number;
  icon: string;
  is_read: number;
  replied_date: string;
  mod?: string;
  type?: string;
}

export interface SystemNotification {
  replied_date: string;
  type: string;
  icon: string;
  user_name: string;
  user_id: string;
  mod: string;
  note: string;
  is_read: string;
}

export interface Chat {
  sender: number;
  mid: number;
  content: string;
  type: "image" | "text";
  time: string
}

export interface ChatSendContent {
  type: "text" | "image";
  content: string;
}

export interface UploadedFile {
  attachment_id: number;
  dateline: number;
  filename: string;
  size: number;
  path: string;
  remote: number;
  is_image: number;
  width: number;
  thumb: boolean;
  thumbnail_url?: string;
  raw_url?: string;
}

export interface UploadData {
  uploaded: UploadedFile[];
}

export interface UploadResponse {
  code: number;
  message: string;
  data: UploadData;
}

export interface NotificationResponse extends LegacyResponse {
  list: AnPNotification[];
}