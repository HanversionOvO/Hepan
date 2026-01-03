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