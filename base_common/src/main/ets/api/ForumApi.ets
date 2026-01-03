import { ApiClient } from './ApiClient';
import { BaseResponse } from './models/UserModels';
import { http } from '@kit.NetworkKit';
import { LogUtil } from '@pura/harmony-utils';
import { ForumCategory, PostCategories } from './models/ForumModels';

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
    const categories: ForumCategory[] = await ForumApi.getForumCategory();
    try {
      const postCategories: PostCategories[] = [];
      const processCategory = (category: ForumCategory) => {
        if (category.can_post_thread) {
          postCategories.push({
            fid: category.fid,
            name: category.name,
            children: category.children?.filter(child => child.can_post_thread).map(child => ({
              fid: child.fid,
              name: child.name
            } as PostCategories))
          });
        }
      };
      categories.forEach(processCategory);
      return postCategories;
    } catch (error) {
      LogUtil.warn(TAG, 'Failed to parse post categories', error);
      throw new Error('Failed to parse post categories');
    }
  }
}