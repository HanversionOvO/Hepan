import { LogUtil } from '@pura/harmony-utils';
import {
  BaseVM,
  BasicDataSource,
  CommonConstant,
  ForumApi,
  ForumDetails,
  ForumTieSummary,
  TieDetail,
  TieRow,
  TieThread,
  UiState
} from 'base_common';
import { CustomTabItem, LongTakeAnimationProperties, NavTitleButtonModel } from 'base_ui';

const TAG = '[TieContentPageVM]: ';

export class CommentDataSource extends BasicDataSource<TieRow> {
}

@ObservedV2
export class TieContentPageVM extends BaseVM {
  @Trace longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @Trace tieSummary: ForumTieSummary = new ForumTieSummary();
  @Trace tieDetail: TieDetail = new TieDetail();
  @Trace tieThread: TieThread = new TieThread();
  @Trace forumInfo: ForumDetails = new ForumDetails();
  @Trace tieTopic: TieRow = new TieRow();
  @Trace tieComments: TieRow[] = [];
  @Trace forumName: string = '';
  @Trace isSticky: boolean = false;
  @Trace isReachEnd: boolean = false;
  @Trace hasNext: boolean = true;
  @Trace currentImageIndex: number = 0;
  @Trace currentSort: number = 0;
  @Trace currentPage: number = 1;
  @Trace targetPid: string = '';
  @Trace commentLoadingState: UiState = UiState.LOADING;
  @Trace isLoadingMore: boolean = false;
  @Trace sortMethods: CustomTabItem[] = [
    { label: $r('app.string.TieContentPage_sort'), icon: $r('sys.symbol.sort') },
    { label: $r('app.string.TieContentPage_sort_reverse'), icon: $r('sys.symbol.sort_1') },
    { label: $r('app.string.TieContentPage_only_author'), icon: $r('sys.symbol.eye') },
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

  async changeSort(index: number) {
    if (this.currentSort === index) {
      return;
    }
    this.currentSort = index;
    this.commentLoadingState = UiState.LOADING;
    this.tieComments = [];
    this.commentDataSource.setData([]);
    this.currentPage = 1;
    this.hasNext = true;
    this.isReachEnd = false;
    await this.loadData(false);
  }

  private applySortAndFilter(comments: TieRow[]): TieRow[] {
    let result = comments.slice();
    const authorId = this.tieThread.author_id || this.tieSummary.author_id;

    if (this.currentSort === 2 && authorId) {
      result = result.filter((row) => row.author_id === authorId);
    }

    if (this.currentSort === 1) {
      result.sort((a, b) => b.position - a.position);
    }

    return result;
  }

  private updateSummaryFromThread(thread: TieThread) {
    if (!thread || !thread.thread_id) {
      return;
    }
    this.tieSummary.thread_id = thread.thread_id;
    this.tieSummary.subject = thread.subject || this.tieSummary.subject;
    this.tieSummary.author = thread.author || this.tieSummary.author;
    this.tieSummary.author_id = thread.author_id || this.tieSummary.author_id;
    this.tieSummary.dateline = thread.dateline || this.tieSummary.dateline;
    this.tieSummary.replies = thread.replies || this.tieSummary.replies;
    this.tieSummary.views = thread.views || this.tieSummary.views;
  }

  private updatePaging(detail: TieDetail) {
    const total = detail.total || 0;
    const pageSize = detail.page_size || 0;
    const page = detail.page || this.currentPage;
    if (total > 0 && pageSize > 0) {
      this.hasNext = page * pageSize < total;
    } else {
      this.hasNext = false;
    }
  }

  async loadData(isLoadMore: boolean = false) {
    if (!this.tieSummary || !this.tieSummary.thread_id) {
      LogUtil.warn(TAG, 'tieSummary is missing');
      this.commentLoadingState = UiState.ERROR;
      return;
    }

    if (isLoadMore) {
      this.isLoadingMore = true;
    } else {
      if (!this.tieComments || this.tieComments.length === 0) {
        this.commentLoadingState = UiState.LOADING;
      }
    }

    try {
      const detail: TieDetail = await ForumApi.getForumDetail(this.tieSummary.thread_id, this.currentPage);
      this.tieDetail = detail;
      this.tieThread = detail.thread || new TieThread();
      this.forumInfo = detail.forum || new ForumDetails();
      if (this.forumInfo.name) {
        this.forumName = this.forumInfo.name;
      }
      this.updateSummaryFromThread(this.tieThread);

      const rows = detail.rows || [];
      let commentRows = rows;

      if (this.currentPage === 1 && rows.length > 0) {
        this.tieTopic = rows[0];
        commentRows = rows.slice(1);
      }

      const filtered = this.applySortAndFilter(commentRows);

      if (isLoadMore) {
        const combined = [...this.tieComments, ...filtered];
        this.tieComments = this.applySortAndFilter(combined);
      } else {
        this.tieComments = filtered;
      }

      this.commentDataSource.setData(this.tieComments);
      this.updatePaging(detail);
      this.isReachEnd = !this.hasNext;

      if (!isLoadMore) {
        this.commentLoadingState = this.tieComments.length === 0 ? UiState.EMPTY : UiState.SUCCESS;
      }
    } catch (error) {
      LogUtil.error(TAG, `Load data failed: ${JSON.stringify(error)}`);
      if (!isLoadMore) {
        this.commentLoadingState = UiState.ERROR;
      }
    } finally {
      this.isLoadingMore = false;
      this.isRefreshingDetail = false;
    }
  }

  async refresh() {
    this.currentPage = 1;
    this.isRefreshingDetail = true;
    this.hasNext = true;
    this.isReachEnd = false;
    await this.loadData(false);
  }

  async loadMore() {
    if (this.isLoadingMore || !this.tieComments) {
      return;
    }

    if (this.hasNext) {
      this.currentPage++;
      await this.loadData(true);
    } else {
      LogUtil.debug(TAG, 'No more pages');
    }
  }

  async supportTie(isSupport: boolean) {
    const threadId = this.tieThread.thread_id || this.tieSummary.thread_id;
    if (threadId) {
      try {
        await ForumApi.supportTie(threadId, isSupport);
      } catch (error) {
        LogUtil.error(TAG, `Support tie failed: ${JSON.stringify(error)}`);
      }
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
