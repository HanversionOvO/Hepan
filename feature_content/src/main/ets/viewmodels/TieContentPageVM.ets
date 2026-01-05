import { BaseVM, ForumApi, ForumTieSummary, TieDetail } from 'base_common';
import { LongTakeAnimationProperties, NavTitleButtonModel } from 'base_ui';

const TAG = '[TieContentPageVM]: ';

@ObservedV2
export class TieContentPageVM extends BaseVM {
  @Trace longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @Trace tieSummary: ForumTieSummary | null = null;
  @Trace tieDetail: TieDetail | null = null;
  @Trace isSticky: boolean = false;
  @Trace isReachEnd: boolean = false;
  @Trace currentImageIndex: number = 0;
  @Trace currentPage: number = 1;
  @Trace titleButtons: NavTitleButtonModel[] = [];
  @Trace isRefreshingDetail: boolean = false;
  @Trace outerPageScroller: Scroller = new Scroller();
  @Trace detailScroller: Scroller = new Scroller();
  @Trace commentScroller: Scroller = new Scroller();

  async loadData() {
    if (this.tieSummary) {
      this.tieDetail = await ForumApi.getForumDetail(this.tieSummary.thread_id, this.currentPage);
    }
  }
}