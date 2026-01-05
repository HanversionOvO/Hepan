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

export interface TieDetail {
  total: number;
  page_size: number;
  page: number;
  thread: TieThread;
  forum: ForumDetails;
  rows: TieRow[];
}

export interface TieThread {
  thread_id: number;
  forum_id: number;
  type_id: number;
  author: string;
  author_id: number;
  subject: string;
  dateline: number;
  last_post: number;
  last_poster: string;
  views: number;
  replies: number;
  display_order: number;
  is_rated: number;
  special: number;
  attachment: number;
  is_moderated: number,
  has_stick_reply: number,
  is_closed: number,
  recommends: number,
  recommend_add: number,
  recommend_sub: number,
  heats: number,
  status: number,
  favorite_times: number,
  share_times: number,
  stamp: number,
  icon: number,
  cover: number,
  max_position: number,
  comments: number,
  can_reply: boolean
}

export interface TieRow {
  post_id: number;
  forum_id: number;
  thread_id: number;
  position: number;
  is_first: number;
  subject: string;
  support: number,
  oppose: number;
  message: string;
  dateline: number;
  format: number;
  usesig: number;
  smileyoff: number;
  parseurloff: number;
  status: number;
  attachments?: SummaryAttachments[];
  author: string;
  author_id: number;

}

export interface TieAuthor {
  group_id: number;
  level_id: number;
  group_title: string;
  group_subtitle: string;
  group_icon: string;
  ext_credits: Record<string, number>;
  posts: number;
  digests: number;
  medals: number[];
  signature: string;
  signature_format: string;
  custom_title: string;
  online_time: number;
  last_visit: number;
  credits: number;
  register_time: number;
}