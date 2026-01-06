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
  TieDetail,
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
  @Trace tieDetail: TieDetail | null = null;
  @Trace isSticky: boolean = false;
  @Trace isReachEnd: boolean = false;
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
        const result: ForumDetailResponse =
          await ForumApi.getForumDetailOld(this.tieSummary.thread_id, 0, 0, this.currentPage);

        if (result) {
          const topic = result.topic;
          const forumName: string = result.forumName;

          let newComments = result.list;

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
            this.commentDataSource.setData(newComments);
          }

          if (!this.tieComments) {
            this.commentLoadingState = UiState.EMPTY;
          }
        }

      } catch (error) {

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