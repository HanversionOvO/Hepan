import { AppUtil, LogUtil } from '@pura/harmony-utils';
import { preferences } from '@kit.ArkData';
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
  ToastUtil,
  UiState
} from 'base_common';
import { CustomTabItem } from 'base_ui';

// 搜索状态枚举
export enum SearchStatus {
  QUERY = 0, // 初始/无内容状态
  REVIEW = 1, // 预览/建议状态
  RESULT = 2 // 结果列表状态
}

const TAG = '[SearchPageVM]';
const PREF_NAME = 'search_pref';
const KEY_SEARCH_HISTORY = 'search_history_list';

@ObservedV2
export class SearchPageVM extends BaseVM {
  @Trace tabItems: CustomTabItem[] = [
    { label: $r('app.string.SearchPage_query_tie'), icon: $r('sys.symbol.book') },
    { label: $r('app.string.SearchPage_query_user'), icon: $r('sys.symbol.person') }
  ]
  @Trace currentSearchIndex: number = 0;
  @Trace columns: number = 2;
  // 搜索相关状态
  @Trace searchStatus: SearchStatus = SearchStatus.QUERY;
  @Trace keyword: string = '';
  // 历史记录相关
  @Trace searchHistory: string[] = []; // 搜索历史列表
  @Trace historyUiState: UiState = UiState.EMPTY; // 历史记录区域的状态
  @Trace isHistoryDeleteMode: boolean = false; // 是否处于删除模式

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

  constructor() {
    super();
    this.loadHistoryFromDisk();
  }

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
    if (this.searchStatus === SearchStatus.RESULT && this.keyword.trim().length > 0) {
      this.doSearch(true);
    }
  }

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
    this.debounceTimer = setTimeout(() => {
      this.fetchSearchSummary(value);
    }, 500);
  }

  onSearchSubmit(value: string) {
    this.keyword = value;
    if (value.trim().length === 0) {
      return;
    }
    if (this.debounceTimer !== -1) {
      clearTimeout(this.debounceTimer);
    }

    // 保存搜索历史
    this.addHistory(value);

    this.doSearch(true);
  }

  // ================= 历史记录逻辑 =================

  /**
   * 添加历史记录
   */
  addHistory(keyword: string) {
    // 移除已存在的相同关键词，将其移到最前
    const index = this.searchHistory.indexOf(keyword);
    if (index !== -1) {
      this.searchHistory.splice(index, 1);
    }
    this.searchHistory.unshift(keyword);

    // 限制历史记录数量，例如 20 条
    if (this.searchHistory.length > 20) {
      this.searchHistory.pop();
    }

    this.updateHistoryState();
    this.saveHistoryToDisk();
  }

  /**
   * 删除单条历史
   */
  deleteHistoryItem(keyword: string) {
    const index = this.searchHistory.indexOf(keyword);
    if (index !== -1) {
      this.searchHistory.splice(index, 1);
      this.updateHistoryState();
      this.saveHistoryToDisk();
    }
  }

  /**
   * 清空所有历史
   */
  clearHistory() {
    this.searchHistory = [];
    this.updateHistoryState();
    this.isHistoryDeleteMode = false;
    this.saveHistoryToDisk();
  }

  /**
   * 更新历史记录页面的 UI 状态
   */
  private updateHistoryState() {
    if (this.searchHistory.length > 0) {
      this.historyUiState = UiState.SUCCESS;
    } else {
      this.historyUiState = UiState.EMPTY;
    }
  }

  /**
   * 退出删除模式
   */
  exitDeleteMode() {
    this.isHistoryDeleteMode = false;
  }

  // ================= 持久化存储逻辑 =================

  /**
   * 保存历史记录到首选项
   */
  private saveHistoryToDisk(): void {
    try {
      const context = AppUtil.getContext();
      const pref = preferences.getPreferencesSync(context, { name: PREF_NAME });
      pref.putSync(KEY_SEARCH_HISTORY, this.searchHistory);
      pref.flush(); // 强制刷盘
    } catch (err) {
      LogUtil.error(TAG, 'Failed to save search history', JSON.stringify(err));
    }
  }

  /**
   * 从首选项加载历史记录
   */
  private loadHistoryFromDisk(): void {
    try {
      const context = AppUtil.getContext();
      const pref = preferences.getPreferencesSync(context, { name: PREF_NAME });
      // 读取字符串数组，如果不存在则返回空数组
      const history = pref.getSync(KEY_SEARCH_HISTORY, []) as string[];
      // 注意：Preferences 取出的数组可能是 Proxy 对象或者不可变对象，建议浅拷贝一份
      this.searchHistory = [...history];
      this.updateHistoryState();
      LogUtil.info(TAG, `Search history loaded. Count: ${this.searchHistory.length}`);
    } catch (err) {
      LogUtil.error(TAG, 'Failed to load search history', JSON.stringify(err));
      this.searchHistory = [];
      this.updateHistoryState();
    }
  }

  // ================= 搜索逻辑 =================

  private async fetchSearchSummary(keyword: string) {
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

  async doSearch(refresh: boolean = false) {
    if (this.keyword.trim().length === 0) {
      return;
    }
    this.searchStatus = SearchStatus.RESULT;
    this.isLoading = true;
    // 退出删除模式
    this.exitDeleteMode();

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
        const result = await SearchApi.searchThreads(this.keyword, this.page);
        if (refresh) {
          this.threadListDataSource.setData(result.rows);
        } else {
          result.rows.forEach(item => {
            this.threadListDataSource.pushData(item)
          });
        }
        this.hasMore = result.rows.length >= result.page_size;
      } else {
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
      ToastUtil.showError('搜索失败: ' + (e.message || '网络错误'));
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