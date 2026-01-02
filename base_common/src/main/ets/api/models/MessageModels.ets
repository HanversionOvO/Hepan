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

export interface RecentMessage {
  plid: number;
  pmid: number;
  lastUserId: number;
  lastUserName: string;
  lastSummary: string;
  lastDateline: number;
  toUserId: number;
  toUserAvatar: string;
  toUserName: string;
  toUserIsBlack: string;
  isNew: string;
}