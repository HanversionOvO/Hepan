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

export interface PostCategories {
  fid: number;
  name: string;
  children?: PostCategories[];
}