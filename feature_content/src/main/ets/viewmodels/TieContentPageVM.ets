import { LogUtil } from '@pura/harmony-utils';
import { BaseVM, CommonConstant, ForumApi, ForumTieSummary, TieDetail } from 'base_common';
import { CustomTabItem, LongTakeAnimationProperties, NavTitleButtonModel } from 'base_ui';

const TAG = '[TieContentPageVM]: ';

@ObservedV2
export class TieContentPageVM extends BaseVM {
  @Trace longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @Trace tieSummary: ForumTieSummary | null = null;
  @Trace tieDetail: TieDetail | null = null;
  @Trace isSticky: boolean = false;
  @Trace isReachEnd: boolean = false;
  @Trace currentImageIndex: number = 0;
  @Trace currentSort: number = 0;
  @Trace currentPage: number = 1;
  @Trace isLoadingMore: boolean = false; // 新增：标记是否正在加载更多

  @Trace sortMethods: CustomTabItem[] = [
    { label: '正序', icon: $r('sys.symbol.sort') },
    { label: '倒序', icon: $r('sys.symbol.sort_1') },
    { label: '只看楼主', icon: $r('sys.symbol.eye') },
  ];
  @Trace titleButtons: NavTitleButtonModel[] = [
    {
      icon: $r('sys.symbol.share'), onClick: () => {
      // Share logic
    }
    }
  ]
  @Trace isRefreshingDetail: boolean = false;
  @Trace outerPageScroller: Scroller = new Scroller();
  @Trace detailScroller: Scroller = new Scroller();
  @Trace commentScroller: Scroller = new Scroller();

  /**
   * 加载数据
   * @param isLoadMore 是否为加载更多模式
   */
  // feature_content/src/main/ets/viewmodels/TieContentPageVM.ets

  async loadData(isLoadMore: boolean = false) {
    if (this.tieSummary) {
      if (isLoadMore) {
        this.isLoadingMore = true;
      }

      try {
        const detail = await ForumApi.getForumDetail(this.tieSummary.thread_id, this.currentPage);

        if (isLoadMore && this.tieDetail) {
          // [修复] ArkTS 不支持对象展开 (...detail)，需手动构建对象
          // 1. 使用 concat 合并旧数据和新数据的 rows
          const newRows = this.tieDetail.rows.concat(detail.rows);

          // 2. 手动创建新对象并赋值，保留 detail 中的最新元数据（如 total, page 等）
          this.tieDetail = {
            total: detail.total,
            page_size: detail.page_size,
            page: detail.page,
            thread: detail.thread,
            forum: detail.forum,
            rows: newRows
          };
        } else {
          // 刷新或首次加载：直接覆盖
          this.tieDetail = detail;
        }

        LogUtil.debug(TAG, `Loaded page ${this.currentPage}, total rows: ${this.tieDetail.rows.length}`);
      } catch (error) {
        LogUtil.error(TAG, `Load data failed: ${JSON.stringify(error)}`);
        if (isLoadMore) {
          this.currentPage--;
        }
      } finally {
        this.isLoadingMore = false;
        this.isRefreshingDetail = false;
      }
    }
  }

  /**
   * 下拉刷新
   */
  async refresh() {
    this.currentPage = 1;
    this.isRefreshingDetail = true;
    await this.loadData(false);
  }

  /**
   * 加载更多
   */
  async loadMore() {
    // 防止重复加载或在没有数据时加载
    if (this.isLoadingMore || !this.tieDetail) {
      return;
    }

    // 计算总页数，判断是否有下一页
    const totalPages = Math.ceil(this.tieDetail.total / this.tieDetail.page_size);
    if (this.currentPage < totalPages) {
      this.currentPage++;
      await this.loadData(true);
    } else {
      LogUtil.debug(TAG, 'No more pages');
    }
  }

  handleScroll(swiperHeight: number) {
    const yOffset = this.isTabletView
      ? this.detailScroller.currentOffset().yOffset
      : this.outerPageScroller.currentOffset().yOffset;

    const threshold = swiperHeight - (this.window.windowTopPadding + CommonConstant.TopBarHeight);

    const shouldBeSticky = yOffset > threshold;

    if (this.isSticky !== shouldBeSticky) {
      animateTo({ duration: CommonConstant.AnimationDurationNormal }, () => {
        this.isSticky = shouldBeSticky;
      })
    }
  }
}