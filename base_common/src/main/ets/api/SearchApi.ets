import { ApiClient } from './ApiClient';
import { BaseResponse, PaginationData } from './models/UserModels';
import { SearchSummaryData, SearchUser } from './models/SearchModels';
import { ForumTieSummary } from './models/ForumModels';
import http from '@ohos.net.http';
import { LogUtil } from '@pura/harmony-utils';

const TAG = '[SearchApi]: ';

export class SearchApi {
  /**
   * 获取搜索预览结果 (综合搜索)
   * 返回少量的帖子和用户结果，以及精确匹配项
   * @param keyword 搜索关键词
   * @throws Error 当网络请求失败或业务码不为0时抛出
   */
  public static async getSearchSummary(keyword: string): Promise<SearchSummaryData> {
    // 构造请求路径，记得对关键词进行编码
    const path = `/_/search/summary?q=${encodeURIComponent(keyword)}`;

    LogUtil.info(TAG, `Fetching search summary for: ${keyword}`);

    const response = await ApiClient.getInstance().request<BaseResponse<SearchSummaryData>>({
      path: path,
      method: http.RequestMethod.GET,
      includeAuthorization: true,
      includeCookie: true
    });

    if (response.status === 200 && response.data.code === 0) {
      return response.data.data;
    } else {
      const errorMsg = response.data?.message || `Fetch search summary failed, status: ${response.status}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  /**
   * 搜索帖子
   * @param keyword 搜索关键词 (可选)
   * @param page 页码 (默认为 1)
   * @param author 作者用户名 (可选)
   * @param digest 是否只搜索精华帖 (可选，true为只看精华)
   * @throws Error 当网络请求失败或业务码不为0时抛出
   */
  public static async searchThreads(
    keyword?: string,
    page: number = 1,
    author?: string,
    digest?: boolean
  ): Promise<PaginationData<ForumTieSummary>> {
    // 构造基础路径
    let path = `/_/search/threads?page=${page}`;

    // 追加可选参数
    if (keyword) {
      path += `&q=${encodeURIComponent(keyword)}`;
    }
    if (author) {
      path += `&author=${encodeURIComponent(author)}`;
    }
    if (digest) {
      path += `&digest=1`;
    }

    LogUtil.info(TAG, `Searching threads with query: ${path}`);

    const response = await ApiClient.getInstance().request<BaseResponse<PaginationData<ForumTieSummary>>>({
      path: path,
      method: http.RequestMethod.GET,
      includeAuthorization: true,
      includeCookie: true
    });

    if (response.status === 200 && response.data.code === 0) {
      return response.data.data;
    } else {
      const errorMsg = response.data?.message || `Search threads failed, status: ${response.status}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  /**
   * 搜索用户
   * @param keyword 搜索关键词 (可选)
   * @param page 页码 (默认为 1)
   * @throws Error 当网络请求失败或业务码不为0时抛出
   */
  public static async searchUsers(keyword?: string, page: number = 1): Promise<PaginationData<SearchUser>> {
    let path = `/_/search/users?page=${page}`;

    if (keyword) {
      path += `&q=${encodeURIComponent(keyword)}`;
    }

    LogUtil.info(TAG, `Searching users with query: ${path}`);

    const response = await ApiClient.getInstance().request<BaseResponse<PaginationData<SearchUser>>>({
      path: path,
      method: http.RequestMethod.GET,
      includeAuthorization: true,
      includeCookie: true
    });

    if (response.status === 200 && response.data.code === 0) {
      return response.data.data;
    } else {
      const errorMsg = response.data?.message || `Search users failed, status: ${response.status}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }
}