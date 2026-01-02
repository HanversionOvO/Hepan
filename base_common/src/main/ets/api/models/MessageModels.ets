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

export interface MessageSummary {
  new_messages: NewMessagesSummary;
}