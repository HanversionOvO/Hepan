import { LegacyResponse } from '../ApiClient';

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
  constructor(data?: Partial<RecentMessage>) {
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
@ObservedV2
export class PostSummary {
  @Trace reply: number = 0;
  @Trace comment: number = 0;
  @Trace at: number = 0;
  @Trace rate: number = 0;
  @Trace other: number = 0;
}

export interface MessageListBody {
  list: RecentMessage[];
}

export interface PmListItem {
  msgList: Chat[];
}

export interface PmListBody {
  pmList: PmListItem[];
}

export interface SystemNotificationData {
  total: number;
  page_size: number;
  page: number;
  rows: SystemNotification[];
}

@ObservedV2
export class SystemSummary {
  @Trace friend: number = 0;
  @Trace space: number = 0;
  @Trace task: number = 0;
  @Trace report: number = 0;
  @Trace system: number = 0;
  @Trace admin: number = 0;
  @Trace app: number = 0;
}

@ObservedV2
export class NewMessagesSummary {
  @Trace chat: number = 0;
  @Trace posts: PostSummary = new PostSummary();
  @Trace system: SystemSummary = new SystemSummary();
}

@ObservedV2
export class NewChat {
  @Trace last_author_id: number = 0;
  @Trace last_author: string = "";
  @Trace last_summary: string = "";
  @Trace to_uid: number = 0;
  @Trace to_username: string = "";
  @Trace conversation_id: string = "";
  @Trace unread: boolean = false;
  @Trace message_count: number = 0;
  @Trace last_update: number = 0;
  @Trace last_dateline: number = 0;
  @Trace author_id: number = 0;
  @Trace type: string = "";
  @Trace subject: string = "";
  @Trace member_count: number = 0;
  @Trace create_time: number = 0;
}

@ObservedV2
export class MessageSummary {
  @Trace new_messages: NewMessagesSummary = new NewMessagesSummary();
  @Trace new_chats: NewChat[] = [];
}

@ObservedV2
export class AnPNotification {
  @Trace board_name: string = "";
  @Trace board_id: number = 0;
  @Trace topic_id: number = 0;
  @Trace topic_subject: string = "";
  @Trace topic_content?: string;
  @Trace topic_url?: string;
  @Trace reply_content: string = "";
  @Trace reply_url: string = "";
  @Trace reply_remind_id?: number;
  @Trace reply_nick_name: string = "";
  @Trace user_id: number = 0;
  @Trace icon: string = "";
  @Trace is_read: number = 0;
  @Trace replied_date: string = "";
  @Trace mod?: string;
  @Trace type?: string;
}

@ObservedV2
export class SystemNotification {
  @Trace id: number = 0;
  @Trace user_id: number = 0;
  @Trace type: string = "";
  @Trace unread: boolean = false;
  @Trace author_id: number = 0;
  @Trace author: string = "";
  @Trace html_message: string = "";
  @Trace message: string = "";
  @Trace dateline: number = 0;
  @Trace from_id: number = 0;
  @Trace from_id_type: string = "";
  @Trace from_num: number = 0;
  @Trace category: number = 0;
  @Trace friend_note: string = "";
}

@ObservedV2
export class Chat {
  @Trace sender: number = 0;
  @Trace mid: number = 0;
  @Trace content: string = "";
  @Trace type: "image" | "text" = "text";
  @Trace time: string = ""
}

@ObservedV2
export class ChatSendContent {
  @Trace type: "text" | "image" = "text";
  @Trace content: string = "";
}

@ObservedV2
export class UploadedFile {
  @Trace attachment_id: number = 0;
  @Trace dateline: number = 0;
  @Trace filename: string = "";
  @Trace size: number = 0;
  @Trace path: string = "";
  @Trace remote: number = 0;
  @Trace is_image: number = 0;
  @Trace width: number = 0;
  @Trace thumb: boolean = false;
  @Trace thumbnail_url?: string;
  @Trace raw_url?: string;
}

@ObservedV2
export class UploadData {
  @Trace uploaded: UploadedFile[] = [];
}

export interface UploadResponse {
  code: number;
  message: string;
  data: UploadData;
}

export interface NotificationResponse extends LegacyResponse {
  list: AnPNotification[];
}
