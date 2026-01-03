import { ApiClient } from './ApiClient';
import { BaseResponse } from './models/UserModels';
import { http } from '@kit.NetworkKit';
import { LogUtil } from '@pura/harmony-utils';
import { AtUser, ForumCategory, PostCategories } from './models/ForumModels';

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
      // 抛出具体错误供 VM 处理
      const errorMsg = response.data?.message || `Fetch profile failed, status: ${response.status}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  public static async getPostCategories(): Promise<PostCategories[]> {
    try {
      const categories: ForumCategory[] = await ForumApi.getForumCategory();
      const result: PostCategories[] = [];

      for (const group of categories) {
        const keptChildren: PostCategories[] = [];
        const promotedChildren: PostCategories[] = [];

        if (group.children && group.children.length > 0) {
          for (const child of group.children) {
            if (child.children && child.children.length > 0) {
              const validSubChildren: PostCategories[] = [];
              child.children.forEach(sub => {
                if (sub.can_post_thread) {
                  const subCat: PostCategories = {
                    fid: sub.fid,
                    name: sub.name
                  };
                  validSubChildren.push(subCat);
                }
              });

              if (validSubChildren.length > 0) {
                const promoted: PostCategories = {
                  fid: child.fid,
                  name: child.name,
                  children: validSubChildren
                };
                promotedChildren.push(promoted);
              }

            } else {
              if (child.can_post_thread) {
                const kept: PostCategories = {
                  fid: child.fid,
                  name: child.name
                };
                keptChildren.push(kept);
              }
            }
          }
        }

        if (keptChildren.length > 0) {
          const newGroup: PostCategories = {
            fid: group.fid,
            name: group.name,
            children: keptChildren
          };
          result.push(newGroup);
        }

        promotedChildren.forEach(item => {
          result.push(item);
        });
      }

      return result;

    } catch (error) {
      LogUtil.warn(TAG, 'Failed to parse post categories', error);
      throw new Error('Failed to parse post categories');
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
      // 抛出具体错误供 VM 处理
      const errorMsg = response.data?.message || `Fetch profile failed, status: ${response.status}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }
}