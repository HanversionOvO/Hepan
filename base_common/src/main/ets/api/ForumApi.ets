import { ApiClient } from './ApiClient';
import { BaseResponse } from './models/UserModels';
import { http } from '@kit.NetworkKit';
import { LogUtil } from '@pura/harmony-utils';
import {
  AtUser,
  ForumCategory,
  ForumDetailResponse,
  ForumDetails,
  ForumTieSummary,
  NewThreadRequest,
  NewThreadResponse,
  PostCategoryGroup,
  PostCategoryItem,
  ReplyRequest,
  ReplyResponse,
  ThreadListResponse,
  TieDetail
} from './models/ForumModels';
import { ToastUtil } from '../utils/ToastUtil';

const TAG = '[ForumApi]: ';

export class ForumApi {
  public static async getForumCategory(): Promise<ForumCategory[]> {
    const path = `/_/index?forum_list=1`;

    const response = await ApiClient.getInstance().request<BaseResponse<Record<string, Object>>>({
      path: path,
      method: http.RequestMethod.GET,
      includeAuthorization: true,
      includeCookie: true
    });

    if (response.status === 200 && response.data.code === 0) {
      return response.data.data["forum_list"] as ForumCategory[];
    } else {
      const errorMsg = response.data?.message || `Fetch forum list failed, status: ${response.status}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  public static async getPostCategories(): Promise<PostCategoryGroup[]> {
    try {
      const categories: ForumCategory[] = await ForumApi.getForumCategory();
      const result: PostCategoryGroup[] = [];

      const extractForums = (node: ForumCategory, list: PostCategoryItem[], parentName: string = '') => {

        const isLeafOrPostable = node.can_post_thread;

        if (isLeafOrPostable && node.fid > 0) {
          list.push({
            fid: node.fid,
            name: node.name,
            parentName: parentName
          });
        }

        if (node.children && node.children.length > 0) {
          node.children.forEach(child => {
            extractForums(child, list, node.name);
          });
        }
      };

      for (const group of categories) {
        const groupItems: PostCategoryItem[] = [];

        if (group.children && group.children.length > 0) {
          group.children.forEach(child => {
            extractForums(child, groupItems, '');
          });
        }

        if (groupItems.length > 0) {
          result.push({
            fid: group.fid,
            name: group.name,
            children: groupItems
          });
        }
      }

      return result;

    } catch (error) {
      LogUtil.warn(TAG, 'Failed to parse post categories', error);
      throw new Error('Failed to parse post categories');
    }
  }

  public static async getForumDetails(fid: number): Promise<ForumDetails> {
    const path = `/_/forum/details?forum_id=${fid}`;

    const response = await ApiClient.getInstance().request<BaseResponse<ForumDetails>>({
      path: path,
      method: http.RequestMethod.GET,
      includeAuthorization: true,
      includeCookie: true
    });

    if (response.status === 200 && response.data.code === 0) {
      return response.data.data;
    } else {
      const errorMsg = response.data?.message || `Fetch forum details failed, status: ${response.status}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  public static async getAtUser(): Promise<AtUser[]> {
    const path = '/_/post/atlist';

    const response = await ApiClient.getInstance().request<BaseResponse<Record<string, Object>>>({
      path: path,
      method: http.RequestMethod.GET,
      includeAuthorization: true,
      includeCookie: true
    });

    if (response.status === 200 && response.data.code === 0 && response.data.data) {
      return response.data.data["rows"] as AtUser[];
    } else {
      const errorMsg = response.data?.message || `Fetch at list failed, status: ${response.status}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  public static async newThread(request: NewThreadRequest): Promise<NewThreadResponse> {
    const path = '/_/thread/new';

    const response = await ApiClient.getInstance().request<BaseResponse<NewThreadResponse>>({
      path: path,
      method: http.RequestMethod.POST,
      includeAuthorization: true,
      includeCookie: true,
      data: request,
    });

    if (response.status === 200 && response.data.code === 0) {
      return response.data.data;
    } else {
      const errorMsg = response.data?.message || `Publish thread failed, status: ${response.status}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  public static async getForumTie(idlist: "newreply" | "newthread" | "digest" | "life" | "hotlist" | "allreplies" | "allvisits",
    page: number = 1): Promise<ForumTieSummary[]> {
    const path: string = `/_/forum/toplist?idlist=${idlist}&page=${page}`

    const response = await ApiClient.getInstance().request<BaseResponse<Record<string, Object>>>({
      path: path,
      method: http.RequestMethod.GET,
      includeAuthorization: true,
      includeCookie: true,
    });

    if (response.status === 200 && response.data.code === 0 && response.data.data) {
      const ties: ForumTieSummary[] = response.data.data[idlist] as ForumTieSummary[];
      return ties;
    } else {
      const errorMsg = response.data?.message || `Publish thread failed, status: ${response.status}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  public static async getForumDetail(tid: number, page: number = 1): Promise<TieDetail> {
    const path: string = `/_/post/list?thread_id=${tid}&page=${page}&thread_details=1&forum_details=1`

    const response = await ApiClient.getInstance().request<BaseResponse<TieDetail>>({
      path: path,
      method: http.RequestMethod.GET,
      includeAuthorization: true,
      includeCookie: true,
    });

    if (response.status === 200 && response.data.code === 0 && response.data.data) {
      const tieDetail: TieDetail = response.data.data;
      return tieDetail;
    } else {
      const errorMsg = response.data?.message || `Publish thread failed, status: ${response.status}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  public static async getForumDetailOld(tid: number, authorId: number = 0, order: number = 0, page: number = 1,
    pageSize: number = 15): Promise<ForumDetailResponse> {
    const response = await ApiClient.getInstance().requestLegacy<ForumDetailResponse>('forum', 'postlist', {
      "topicId": tid,
      "authorId": authorId,
      "order": order,
      "page": page,
      "pageSize": pageSize
    });

    if (response.status === 200) {
      const result: ForumDetailResponse = response.data
      return result;
    } else {
      const errorMsg = response.data.head?.errInfo || `Publish thread failed, status: ${response.status}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  public static async supportTie(tid: number, isSupport: boolean): Promise<number> {
    const path = `/_/post/review?tid=${tid}&support=${isSupport ? "true" : "false"}`;

    const response = await ApiClient.getInstance().request<BaseResponse<number>>({
      path: path,
      method: http.RequestMethod.POST,
      includeAuthorization: true,
      includeCookie: true,
    });

    if (response.status === 200 && response.data.code === 0) {
      return response.data.data;
    } else {
      const errorMsg = response.data?.message || `Publish thread failed, status: ${response.status}`;
      LogUtil.warn(TAG, errorMsg);
      ToastUtil.showError(response.data.message);
      throw new Error(errorMsg);
    }
  }

  public static async reply(request: ReplyRequest): Promise<ReplyResponse> {
    const path = '/_/thread/reply';

    const response = await ApiClient.getInstance().request<BaseResponse<ReplyResponse>>({
      path: path,
      method: http.RequestMethod.POST,
      includeAuthorization: true,
      includeCookie: true,
      data: request,
    });

    if (response.status === 200 && response.data.code === 0) {
      return response.data.data;
    } else {
      const errorMsg = response.data?.message || `Reply failed, status: ${response.status}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  public static async getForumThreads(forumId: number, sortBy: number, page: number = 1): Promise<ForumTieSummary[]> {
    const path: string = `/_/thread/list?forum_id=${forumId}&page=${page}&sort_by=${sortBy}&forum_details=1`;

    const response = await ApiClient.getInstance().request<BaseResponse<ThreadListResponse>>({
      path: path,
      method: http.RequestMethod.GET,
      includeAuthorization: true,
      includeCookie: true,
    });

    if (response.status === 200 && response.data.code === 0 && response.data.data) {
      // 接口返回的数据结构中 rows 包含帖子列表
      return response.data.data.rows || [];
    } else {
      const errorMsg = response.data?.message || `Fetch forum threads failed, status: ${response.status}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }
}