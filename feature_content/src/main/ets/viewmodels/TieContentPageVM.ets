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
  @Trace sortMethods: CustomTabItem[] = [
    { label: '正序', icon: $r('sys.symbol.sort') },
    { label: '倒序', icon: $r('sys.symbol.sort_1') },
    { label: '只看楼主', icon: $r('sys.symbol.eye') },
  ];
  @Trace titleButtons: NavTitleButtonModel[] = [
    {
      icon: $r('sys.symbol.share'), onClick: () => {
    }
    }
  ]
  @Trace isRefreshingDetail: boolean = false;
  @Trace outerPageScroller: Scroller = new Scroller();
  @Trace detailScroller: Scroller = new Scroller();
  @Trace commentScroller: Scroller = new Scroller();
  @Trace isLoadingMore: boolean = false;
  @Trace hasMore: boolean = true;

  async loadData(isLoadMore: boolean = false) {
    if (!this.tieSummary) {
      return;
    }

    // 防止重复加载
    if (this.isLoading || this.isLoadingMore) {
      return;
    }

    if (isLoadMore) {
      this.isLoadingMore = true;
    } else {
      this.isRefreshingDetail = true;
      this.currentPage = 1;
      this.hasMore = true;
    }

    try {
      const result = await ForumApi.getForumDetail(this.tieSummary.thread_id, this.currentPage);

      if (isLoadMore) {
        if (this.tieDetail && result.rows && result.rows.length > 0) {
          this.tieDetail.rows.push(...result.rows);
          this.currentPage++;
        } else {
          this.hasMore = false;
        }
      } else {
        this.tieDetail = result;
        if (!result.rows || result.rows.length === 0) {
          this.hasMore = false;
        } else {
          this.currentPage++; // 准备加载下一页
        }
      }
      LogUtil.debug(TAG, `Load data success. Page: ${this.currentPage}, LoadMore: ${isLoadMore}`);
    } catch (error) {
      LogUtil.error(TAG, `Load data failed: ${JSON.stringify(error)}`);
    } finally {
      this.isRefreshingDetail = false;
      this.isLoadingMore = false;
    }
  }

  async onRefresh() {
    await this.loadData(false);
  }

  async onLoadMore() {
    if (this.hasMore && !this.isLoadingMore && !this.isRefreshingDetail) {
      await this.loadData(true);
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