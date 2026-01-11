import { AppUtil, LogUtil } from '@pura/harmony-utils';
import {
  BaseVM,
  BasicDataSource,
  BreakpointNameEnum,
  BreakpointType,
  CommonConstant,
  ForumTieSummary,
  RouterUtil,
  SearchApi,
  SearchSummaryData,
  SearchUser,
} from 'base_common';
import { CustomTabItem } from 'base_ui';

// 搜索状态枚举
export enum SearchStatus {
  QUERY = 0, // 初始/无内容状态
  REVIEW = 1, // 预览/建议状态
  RESULT = 2 // 结果列表状态
}

const TAG = '[SearchPageVM]';

@ObservedV2
export class SearchPageVM extends BaseVM {
  @Trace tabItems: CustomTabItem[] = [
    { label: $r('app.string.SearchPage_query_tie'), icon: $r('sys.symbol.book') },
    { label: $r('app.string.SearchPage_query_user'), icon: $r('sys.symbol.person') }
  ]
  @Trace currentSearchIndex: number = 0; // 0: 搜帖子, 1: 搜用户
  @Trace columns: number = 2;
  // 搜索相关状态
  @Trace searchStatus: SearchStatus = SearchStatus.QUERY;
  @Trace keyword: string = '';
  // 预览数据
  @Trace searchSummary: SearchSummaryData | null = null;
  // 结果数据
  @Trace threadListDataSource: BasicDataSource<ForumTieSummary> = new BasicDataSource();
  @Trace userListDataSource: BasicDataSource<SearchUser> = new BasicDataSource();
  // 分页控制
  private page: number = 1;
  @Trace hasMore: boolean = true;
  @Trace isLoading: boolean = false;
  // 防抖计时器
  private debounceTimer: number = -1;

  @Monitor("breakPoint.currentBreakPoint")
  onBreakpointChange() {
    this.updateGridConfig(this.breakPoint.currentBreakPoint);
  }

  private defaultColumnsConfig = new BreakpointType({
    sm: 1,
    md: 2,
    lg: 4,
    xl: 5
  });

  updateGridConfig(bp: BreakpointNameEnum) {
    this.columns = this.defaultColumnsConfig.getValue(bp);
  }

  back() {
    AppUtil.getUIContext()
      .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveNormal },
        () => {
          RouterUtil.pop(undefined, false);
        })
  }

  changeTab(index: number) {
    if (this.currentSearchIndex === index) {
      return;
    }
    this.currentSearchIndex = index;

    // 如果当前已经在结果页，切换 Tab 后需要重新搜索对应内容
    if (this.searchStatus === SearchStatus.RESULT && this.keyword.trim().length > 0) {
      this.doSearch(true);
    }
  }

  /**
   * 搜索框内容变化时触发
   * @param value 输入的内容
   */
  onSearchInputChange(value: string) {
    this.keyword = value;

    if (this.debounceTimer !== -1) {
      clearTimeout(this.debounceTimer);
    }

    if (value.trim().length === 0) {
      this.searchStatus = SearchStatus.QUERY;
      this.searchSummary = null;
      return;
    }

    // 防抖 500ms 后请求预览
    this.debounceTimer = setTimeout(() => {
      this.fetchSearchSummary(value);
    }, 500);
  }

  /**
   * 提交搜索时触发
   */
  onSearchSubmit(value: string) {
    this.keyword = value;
    if (value.trim().length === 0) {
      return;
    }

    // 清除预览请求（如果还在pending）
    if (this.debounceTimer !== -1) {
      clearTimeout(this.debounceTimer);
    }

    this.doSearch(true);
  }

  /**
   * 获取搜索预览数据
   */
  private async fetchSearchSummary(keyword: string) {
    // 如果用户已经提交了搜索，不再更新预览
    if (this.searchStatus === SearchStatus.RESULT) {
      return;
    }

    try {
      const data = await SearchApi.getSearchSummary(keyword);
      this.searchSummary = data;
      this.searchStatus = SearchStatus.REVIEW;
    } catch (e) {
      LogUtil.error(TAG, `Fetch summary failed: ${JSON.stringify(e)}`);
    }
  }

  /**
   * 执行正式搜索
   * @param refresh 是否重置分页
   */
  async doSearch(refresh: boolean = false) {
    if (this.keyword.trim().length === 0) {
      return;
    }

    this.searchStatus = SearchStatus.RESULT;
    this.isLoading = true;

    if (refresh) {
      this.page = 1;
      this.hasMore = true;
      if (this.currentSearchIndex === 0) {
        this.threadListDataSource.setData([]);
      } else {
        this.userListDataSource.setData([]);
      }
    }

    try {
      if (this.currentSearchIndex === 0) {
        // 搜索帖子
        const result = await SearchApi.searchThreads(this.keyword, this.page);
        if (refresh) {
          this.threadListDataSource.setData(result.rows);
        } else {
          result.rows.forEach(item => {
            this.threadListDataSource.pushData(item)
          });
        }
        this.hasMore = result.rows.length >= result.page_size; // 简单判断
      } else {
        // 搜索用户
        const result = await SearchApi.searchUsers(this.keyword, this.page);
        if (refresh) {
          this.userListDataSource.setData(result.rows);
        } else {
          result.rows.forEach(item => {
            this.userListDataSource.pushData(item)
          });
        }
        this.hasMore = result.rows.length >= result.page_size;
      }

      if (this.hasMore) {
        this.page++;
      }
    } catch (e) {
      LogUtil.error(TAG, `Search failed: ${JSON.stringify(e)}`);
    } finally {
      this.isLoading = false;
    }
  }

  loadMore() {
    if (!this.isLoading && this.hasMore) {
      this.doSearch(false);
    }
  }
}