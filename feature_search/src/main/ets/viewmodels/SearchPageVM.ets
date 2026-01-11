import { AppUtil, LogUtil } from '@pura/harmony-utils';
import { preferences } from '@kit.ArkData';
import {
  BaseVM,
  BasicDataSource,
  BreakpointNameEnum,
  BreakpointType,
  CommonConstant,
  ForumTieSummary,
  RouterMap,
  RouterUtil,
  SearchApi,
  SearchSummaryData,
  SearchUser,
  ToastUtil,
  UiState
} from 'base_common';
import { CustomTabItem, LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'base_ui';
import { curves } from '@kit.ArkUI';
import { LongTakeTransitionOptions } from 'base_ui/src/main/ets/transitions/longtake/utils/Options';

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
  @Trace postColumn: number = 2;
  // 搜索相关状态
  @Trace searchStatus: SearchStatus = SearchStatus.QUERY;
  @Trace keyword: string = '';
  // 历史记录相关
  @Trace searchHistory: string[] = [];
  @Trace historyUiState: UiState = UiState.EMPTY;
  @Trace isHistoryDeleteMode: boolean = false;
  // 搜索结果相关 UI 状态 [新增]
  @Trace resultUiState: UiState = UiState.LOADING;
  // 页面缩放比例（用于一镜到底转场动画） [新增]
  @Trace pageScale: number = 1.0;
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
  private postColumnsConfig = new BreakpointType({
    sm: 2,
    md: 3,
    lg: 4,
    xl: 5
  })

  updateGridConfig(bp: BreakpointNameEnum) {
    this.columns = this.defaultColumnsConfig.getValue(bp);
    this.postColumn = this.postColumnsConfig.getValue(bp);
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
    // 切换 Tab 时，如果有搜索词且在结果页，立即执行新类型的搜索
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
    // 输入时只请求预览，不改变 Result 状态
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

    // 执行搜索
    this.doSearch(true);
  }

  // ================= 历史记录逻辑 =================
  // (保持原有逻辑不变)
  addHistory(keyword: string) {
    const index = this.searchHistory.indexOf(keyword);
    if (index !== -1) {
      this.searchHistory.splice(index, 1);
    }
    this.searchHistory.unshift(keyword);
    if (this.searchHistory.length > 20) {
      this.searchHistory.pop();
    }
    this.updateHistoryState();
    this.saveHistoryToDisk();
  }

  deleteHistoryItem(keyword: string) {
    const index = this.searchHistory.indexOf(keyword);
    if (index !== -1) {
      this.searchHistory.splice(index, 1);
      this.updateHistoryState();
      this.saveHistoryToDisk();
    }
  }

  clearHistory() {
    this.searchHistory = [];
    this.updateHistoryState();
    this.isHistoryDeleteMode = false;
    this.saveHistoryToDisk();
  }

  private updateHistoryState() {
    this.historyUiState = this.searchHistory.length > 0 ? UiState.SUCCESS : UiState.EMPTY;
  }

  exitDeleteMode() {
    this.isHistoryDeleteMode = false;
  }

  private saveHistoryToDisk(): void {
    try {
      const context = AppUtil.getContext();
      const pref = preferences.getPreferencesSync(context, { name: PREF_NAME });
      pref.putSync(KEY_SEARCH_HISTORY, this.searchHistory);
      pref.flush();
    } catch (err) {
      LogUtil.error(TAG, 'Failed to save search history', JSON.stringify(err));
    }
  }

  private loadHistoryFromDisk(): void {
    try {
      const context = AppUtil.getContext();
      const pref = preferences.getPreferencesSync(context, { name: PREF_NAME });
      const history = pref.getSync(KEY_SEARCH_HISTORY, []) as string[];
      this.searchHistory = [...history];
      this.updateHistoryState();
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
    this.exitDeleteMode();

    if (refresh) {
      // 刷新时重置状态为 LOADING
      this.resultUiState = UiState.LOADING;
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
        // --- 搜帖子 ---
        const result = await SearchApi.searchThreads(this.keyword, this.page);
        if (refresh) {
          if (result.rows.length === 0) {
            this.resultUiState = UiState.EMPTY;
          } else {
            this.resultUiState = UiState.SUCCESS;
            this.threadListDataSource.setData(result.rows);
          }
        } else {
          result.rows.forEach(item => {
            this.threadListDataSource.pushData(item)
          });
        }
        this.hasMore = result.rows.length >= result.page_size;
      } else {
        // --- 搜用户 ---
        const result = await SearchApi.searchUsers(this.keyword, this.page);
        if (refresh) {
          if (result.rows.length === 0) {
            this.resultUiState = UiState.EMPTY;
          } else {
            this.resultUiState = UiState.SUCCESS;
            this.userListDataSource.setData(result.rows);
          }
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
      // 只有刷新失败才显示错误页，加载更多失败只弹吐司
      if (refresh) {
        this.resultUiState = UiState.ERROR;
      } else {
        ToastUtil.showError('加载更多失败: ' + (e.message || '网络错误'));
      }
    } finally {
      this.isLoading = false;
    }
  }

  loadMore() {
    if (!this.isLoading && this.hasMore && this.resultUiState === UiState.SUCCESS) {
      this.doSearch(false);
    }
  }

  // ================= 详情页跳转与动画逻辑 =================

  /**
   * 进入帖子详情页，带一镜到底动画
   */
  enterDetailPage(tid: string, context: UIContext, tieSummary: ForumTieSummary) {
    let options: LongTakeTransitionOptions = {
      onEnterTransitionStart: () => {
        // 进场时缩放页面
        context.animateTo({ curve: curves.springMotion(0.35, 0.75) }, () => {
          this.pageScale = 0.95;
        })
      },
      onBackTransitionStart: () => {
        // 返回时恢复页面
        context.animateTo({ curve: curves.springMotion(0.35, 0.75) }, () => {
          this.pageScale = 1.0;
        })
      }
    };

    let longTakeTransitionParam: LongTakeTransitionParam | undefined =
      LoneTakeAnimationsTransition.generateLongTakeParam(context,
        tid, CommonConstant.RadiusLarge, options);

    const params: Record<string, Object> = {};

    if (longTakeTransitionParam) {
      let transitionParam: LongTakeTransitionParam = longTakeTransitionParam;
      params["transition"] = transitionParam;
    }

    params["tieSummary"] = tieSummary;

    RouterUtil.pushPathByName(RouterMap.TIE_CONTENT_PAGE, params);
  }
}