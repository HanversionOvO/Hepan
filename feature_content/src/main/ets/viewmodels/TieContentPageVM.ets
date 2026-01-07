import { LogUtil } from '@pura/harmony-utils';
import {
  BaseVM,
  BasicDataSource,
  CommonConstant,
  ForumApi,
  ForumDetailComment,
  ForumDetailResponse,
  ForumDetailTopic,
  ForumTieSummary,
  UiState
} from 'base_common';
import { CustomTabItem, LongTakeAnimationProperties, NavTitleButtonModel } from 'base_ui';

const TAG = '[TieContentPageVM]: ';

export class CommentDataSource extends BasicDataSource<ForumDetailComment> {
}

@ObservedV2
export class TieContentPageVM extends BaseVM {
  @Trace longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @Trace tieSummary: ForumTieSummary | null = null;
  @Trace tieTopic: ForumDetailTopic | null = null;
  @Trace tieComments: ForumDetailComment[] | null = null;
  @Trace forumName: string = '';
  @Trace isSticky: boolean = false;
  @Trace isReachEnd: boolean = false;
  @Trace hasNext: number = 1;
  @Trace currentImageIndex: number = 0;
  @Trace currentSort: number = 0;
  @Trace currentPage: number = 1;
  @Trace commentLoadingState: UiState = UiState.LOADING;
  @Trace isLoadingMore: boolean = false;
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

  async changeSort(index: number) {
    if (this.currentSort === index) {
      return;
    }
    this.currentSort = index;
    this.commentLoadingState = UiState.LOADING;
    this.tieComments = [];
    this.commentDataSource.setData([]);
    this.currentPage = 1;
    this.hasNext = 1;
    this.isReachEnd = false;
    await this.loadData(false);
  }

  /**
   * 加载数据
   * @param isLoadMore 是否为加载更多模式
   */
  async loadData(isLoadMore: boolean = false) {
    if (this.tieSummary) {
      if (isLoadMore) {
        this.isLoadingMore = true;
      } else {
        if (!this.tieComments || this.tieComments.length === 0) {
          this.commentLoadingState = UiState.LOADING;
        }
      }

      try {
        let order = 0;
        let authorId = 0;
        if (this.currentSort === 1) {
          order = 1; // 倒序
        } else if (this.currentSort === 2) {
          authorId = this.tieSummary.author_id; // 只看楼主
        }

        const result: ForumDetailResponse =
          await ForumApi.getForumDetailOld(this.tieSummary.thread_id, authorId, order, this.currentPage);

        if (result) {
          const topic = result.topic;
          const forumName: string = result.forumName;
          this.hasNext = result.has_next;
          this.isReachEnd = this.hasNext === 0;

          let newComments = result.list || [];

          if (this.currentPage === 1 && newComments.length > 0 && newComments[0].position === 1) {
            newComments = newComments.slice(1);
          }

          if (isLoadMore && this.tieComments) {
            const allRows = this.tieComments.concat(newComments);
            this.tieComments = allRows;
            this.commentDataSource.addData(newComments);
          } else {
            this.tieTopic = topic;
            this.forumName = forumName;
            this.tieComments = newComments;
            this.commentDataSource.setData(newComments);

            if (this.tieComments.length === 0) {
              this.commentLoadingState = UiState.EMPTY;
            } else {
              this.commentLoadingState = UiState.SUCCESS;
            }
          }
        } else {
          if (!isLoadMore && !this.tieComments) {
            this.commentLoadingState = UiState.EMPTY;
          }
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
  }

  /**
   * 下拉刷新
   */
  async refresh() {
    this.currentPage = 1;
    this.isRefreshingDetail = true;
    this.hasNext = 1; // 重置分页状态
    this.isReachEnd = false;
    await this.loadData(false);
  }

  /**
   * 加载更多
   */
  async loadMore() {
    // 防止重复加载或在没有数据时加载
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
    if (this.tieSummary && this.tieTopic) {
      try {
        await ForumApi.supportTie(this.tieSummary.thread_id, isSupport);
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