import { LegacyResponse } from './ApiModels';
import { UploadedFile } from './MessageModels';

@ObservedV2
export class ForumCategory {
  @Trace fid: number = 0;
  @Trace name: string = "";
  @Trace can_post_thread: boolean = false;
  @Trace can_post_reply: boolean = false;
  @Trace hidden_home: boolean = false;
  @Trace threads: number = 0;
  @Trace posts: number = 0;
  @Trace todayposts: number = 0;
  @Trace yesterdayposts: number = 0;
  @Trace latest_thread?: LatestThread[] = [];
  @Trace moderators: string[] = [];
  @Trace children?: ForumCategory[];
}

@ObservedV2
export class LatestThread {
  @Trace thread_id: number = 0;
  @Trace subject: string = "";
  @Trace lastpost_time: number = 0;
  @Trace lastpost_author: string = "";
  @Trace lastpost_authorid: number = 0;
}

@ObservedV2
export class PostCategoryGroup {
  @Trace fid: number = 0;
  @Trace name: string = "";
  @Trace children: PostCategoryItem[] = [];
}

@ObservedV2
export class PostCategoryItem {
  @Trace fid: number = 0;
  @Trace name: string = "";
  @Trace description?: string;
  @Trace parentName?: string;
}

@ObservedV2
export class AtUser {
  @Trace uid: number = 0;
  @Trace username: string = "";
  @Trace status: string = "";
}

@ObservedV2
export class ForumDetails {
  @Trace fid: number = 0;
  @Trace name: string = "";
  @Trace thread_types: ThreadType[] = [];
  @Trace optional_thread_type: boolean = false;
  @Trace can_post_thread: boolean = false;
  @Trace children?: ForumCategory[];
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

@ObservedV2
export class ForumTieSummary {
  @Trace thread_id: number = 0;
  @Trace forum_id: number = 0;
  @Trace type_id: number = 0;
  @Trace author: string = "";
  @Trace author_id: number = 0;
  @Trace subject: string = "";
  @Trace summary: string = "";
  @Trace summary_attachments?: SummaryAttachments[];
  @Trace dateline: number = 0;
  @Trace last_post: number = 0;
  @Trace views: number = 0;
  @Trace replies: number = 0;
  @Trace label: string = "";
  @Trace recommend_add: number = 0;
  @Trace recommend_sub: number = 0;
  @Trace forum_name?: string;
  @Trace display_order: number = 0;
}

@ObservedV2
export class TieDetail {
  @Trace total: number = 0;
  @Trace page_size: number = 0;
  @Trace page: number = 0;
  @Trace thread: TieThread = new TieThread();
  @Trace forum: ForumDetails = new ForumDetails();
  @Trace rows: TieRow[] = [];
}

@ObservedV2
export class TieThread {
  @Trace thread_id: number = 0;
  @Trace forum_id: number = 0;
  @Trace type_id: number = 0;
  @Trace author: string = "";
  @Trace author_id: number = 0;
  @Trace subject: string = "";
  @Trace dateline: number = 0;
  @Trace last_post: number = 0;
  @Trace last_poster: string = "";
  @Trace views: number = 0;
  @Trace replies: number = 0;
  @Trace display_order: number = 0;
  @Trace is_rated: number = 0;
  @Trace special: number = 0;
  @Trace attachment: number = 0;
  @Trace is_moderated: number = 0;
  @Trace has_stick_reply: number = 0;
  @Trace is_closed: number = 0;
  @Trace recommends: number = 0;
  @Trace recommend_add: number = 0;
  @Trace recommend_sub: number = 0;
  @Trace heats: number = 0;
  @Trace status: number = 0;
  @Trace favorite_times: number = 0;
  @Trace share_times: number = 0;
  @Trace stamp: number = 0;
  @Trace icon: number = 0;
  @Trace cover: number = 0;
  @Trace max_position: number = 0;
  @Trace comments: number = 0;
  @Trace can_reply: boolean = false;
}

@ObservedV2
export class TieRow {
  @Trace post_id: number = 0;
  @Trace forum_id: number = 0;
  @Trace thread_id: number = 0;
  @Trace position: number = 0;
  @Trace is_first: number = 0;
  @Trace subject: string = "";
  @Trace support: number = 0;
  @Trace oppose: number = 0;
  @Trace message: string = "";
  @Trace dateline: number = 0;
  @Trace format: number = 0;
  @Trace usesig: number = 0;
  @Trace smileyoff: number = 0;
  @Trace parseurloff: number = 0;
  @Trace status: number = 0;
  @Trace attachments?: SummaryAttachments[];
  @Trace author: string = "";
  @Trace author_id: number = 0;
  @Trace author_details: TieAuthor = new TieAuthor();
}

@ObservedV2
export class TieAuthor {
  @Trace group_id: number = 0;
  @Trace level_id: number = 0;
  @Trace group_title?: string;
  @Trace group_subtitle: string = "";
  @Trace group_icon: string = "";
  @Trace ext_credits: Record<string, number> = {};
  @Trace posts: number = 0;
  @Trace digests: number = 0;
  @Trace medals: number[] = [];
  @Trace signature: string = "";
  @Trace signature_format: string = "";
  @Trace custom_title: string = "";
  @Trace online_time: number = 0;
  @Trace last_visit: number = 0;
  @Trace credits: number = 0;
  @Trace register_time: number = 0;
}

@ObservedV2
export class ForumDetailTopic {
  @Trace topic_id: number = 0;
  @Trace title: string = "";
  @Trace format: string = "";
  @Trace type: string = "";
  @Trace special: number = 0;
  @Trace sortId: number = 0;
  @Trace user_id: number = 0;
  @Trace user_nick_name: string = "";
  @Trace replies: number = 0;
  @Trace hits: number = 0;
  @Trace essence: number = 0;
  @Trace vote: number = 0;
  @Trace hot: number = 0;
  @Trace top: number = 0;
  @Trace is_favor: number = 0;
  @Trace create_date: string = "";
  @Trace icon: string = "";
  @Trace level: number = 0;
  @Trace userTitle: string = "";
  @Trace userColor: string = "";
  @Trace isFollow: number = 0;
  // @Trace zanList: Object[]; // 暂未获取到
  @Trace content: ForumDetailReplyContent[] = []; // 内容
  @Trace status: number = 0;
  @Trace reply_status: number = 0;
  @Trace flag: number = 0;
  @Trace gender: number = 0;
  @Trace reply_posts_id: number = 0;
  // @Trace rateList: Object ; // 待做
  // @Trace reward: Object; // 待做
  @Trace extraPanel: ForumExtraPanel[] = [];
}

@ObservedV2
export class ForumDetailComment {
  @Trace reply_id: number = 0;
  @Trace format: string = "";
  @Trace reply_content: ForumDetailReplyContent[] = [];
  @Trace reply_type: string = "";
  @Trace reply_name: string = "";
  @Trace reply_posts_id: number = 0;
  @Trace poststick: number = 0;
  @Trace position: number = 0;
  @Trace posts_date: string = "";
  @Trace icon: string = "";
  @Trace level: number = 0;
  @Trace userTitle: string = "";
  @Trace userColor: string = "";
  @Trace location: string = "";
  @Trace mobileSign: string = "";
  @Trace reply_status: number = 0;
  @Trace status: number = 0;
  @Trace role_num: number = 0;
  @Trace title: string = "";
  @Trace gender: number = 0;
  @Trace is_quote: number = 0;
  @Trace quote_pid: number = 0;
  @Trace quote_content: string = "";
  @Trace quote_content_bare?: string = "";
  @Trace quote_user_name: string = "";
  @Trace delThread: boolean = false;
  @Trace extraPanel: ForumExtraPanel[] = [];
}

@ObservedV2
export class ForumExtraPanel {
  @Trace action: string = '';
  @Trace title: string = '';
  @Trace recommendAdd: string = '';
  @Trace extParams: ForumExtParams = new ForumExtParams();
  @Trace type: string = '';
}

@ObservedV2
export class ForumExtParams {
  @Trace beforeAction: string = "";
  @Trace recommendAdd: number = 0;
  @Trace isHasRecommendAdd: number = 0
}

@ObservedV2
export class ForumDetailReplyContent {
  @Trace infor: string = "";
  @Trace type: number = 0;
  @Trace url?: string;
  @Trace desc?: string;
  @Trace originalInfo?: string;
  @Trace aid?: number;
}

export interface ForumDetailResponse extends LegacyResponse {
  topic: ForumDetailTopic;
  page: number;
  has_next: number;
  total_num: number;
  list: ForumDetailComment[];
  forumName: string;
  boardId: number;
  forumTopicUrl: string;
  img_url: string;
  icon_url: string;
}

export interface ReplyRequest {
  thread_id: number;
  message: string;
  usesig: number;
  is_anonymous: boolean;
  attachments: UploadedFile[];
  format: number;
  post_id?: number;
}

export interface ReplyResponse {
  post_id: number;
}

export interface ThreadListResponse {
  total: number;
  page_size: number;
  page: number;
  rows: ForumTieSummary[];
}