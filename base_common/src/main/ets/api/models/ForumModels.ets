import { UploadedFile } from './MessageModels';

export interface ForumCategory {
  fid: number;
  name: string;
  can_post_thread: boolean;
  can_post_reply: boolean;
  hidden_home: boolean;
  threads: number;
  posts: number;
  todayposts: number;
  yesterdayposts: number;
  latest_thread?: LatestThread[];
  moderators: string[];
  children?: ForumCategory[];
}

export interface LatestThread {
  thread_id: number;
  subject: string;
  lastpost_time: number;
  lastpost_author: string;
  lastpost_authorid: number;
}

export interface PostCategoryGroup {
  fid: number;
  name: string;
  children: PostCategoryItem[];
}

export interface PostCategoryItem {
  fid: number;
  name: string;
  description?: string;
  parentName?: string;
}

export interface AtUser {
  uid: number;
  username: string;
  status: string;
}

export interface ForumDetails {
  fid: number;
  name: string;
  thread_types: ThreadType[];
  optional_thread_type: boolean;
  can_post_thread: boolean;
  children?: ForumCategory[];
}

export interface ThreadType {
  type_id: number;
  name: string;
}

export interface NewThreadRequest {
  forum_id: number;
  type_id: number;
  subject: string;
  message: string;
  format: number;
  usesig: number;
  attachments?: UploadedFile[];
}

export interface NewThreadResponse {
  thread_id: number;
  ext_credits_update?: Record<string, number>;
}

export interface SummaryAttachments {
  attachment_id: number;
  dateline: number;
  filename: string;
  size: number;
  path: string;
  description: string;
  price: number;
  is_image: number;
  width: number;
  thumb: boolean;
  picid: number;
  thumbnail_url: string;
  raw_url: string;
}

export interface ForumTieSummary {
  thread_id: number;
  forum_id: number;
  type_id: number;
  author: string;
  author_id: number;
  subject: string;
  summary: string;
  summary_attachments?: SummaryAttachments[];
  dateline: number;
  last_post: number;
  views: number;
  replies: number;
  label: string;
}