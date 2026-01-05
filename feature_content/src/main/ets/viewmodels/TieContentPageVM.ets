import { LogUtil } from '@pura/harmony-utils';
import { BaseVM, BasicDataSource, CommonConstant, ForumApi, ForumTieSummary, TieDetail, TieRow } from 'base_common';
import { CustomTabItem, LongTakeAnimationProperties, NavTitleButtonModel } from 'base_ui';

const TAG = '[TieContentPageVM]: ';

export class CommentDataSource extends BasicDataSource<TieRow> {
}

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
  commentDataSource: CommentDataSource = new CommentDataSource();

  /**
   * 加载数据
   * @param isLoadMore 是否为加载更多模式
   */
  async loadData(isLoadMore: boolean = false) {
    if (this.tieSummary) {
      if (isLoadMore) {
        this.isLoadingMore = true;
      }

      try {
        const detail = await ForumApi.getForumDetail(this.tieSummary.thread_id, this.currentPage);

        let newComments = detail.rows;

        if (this.currentPage === 1 && newComments.length > 0 && newComments[0].position === 1) {
          newComments = newComments.slice(1);
        }

        if (isLoadMore && this.tieDetail) {
          const allRows = this.tieDetail.rows.concat(detail.rows);
          this.tieDetail = {
            total: detail.total,
            page_size: detail.page_size,
            page: detail.page,
            thread: detail.thread,
            forum: detail.forum,
            rows: allRows
          };

          this.commentDataSource.addData(newComments);

        } else {
          this.tieDetail = detail;

          this.commentDataSource.setData(newComments);
        }

        LogUtil.debug(TAG, `Loaded page ${this.currentPage}`);

      } catch (error) {
        // ... error handling
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