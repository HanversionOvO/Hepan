import { ApiClient } from './ApiClient';
import { BaseResponse } from './models/UserModels';
import { http } from '@kit.NetworkKit';
import { LogUtil } from '@pura/harmony-utils';
import {
  AtUser,
  ForumCategory,
  ForumDetails,
  ForumTieSummary,
  NewThreadRequest,
  NewThreadResponse,
  PostCategoryGroup,
  PostCategoryItem,
  TieDetail
} from './models/ForumModels';

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
      data: request
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
    const path: string = `/_/post/list?thread_id=${tid}&page=${page}`

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
}