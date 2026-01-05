import { LogUtil } from '@pura/harmony-utils';
import { BaseVM, ForumTieSummary, TieDetail } from 'base_common';
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
  @Trace titleButtons: NavTitleButtonModel[] = [];
  @Trace isRefreshingDetail: boolean = false;
  @Trace outerPageScroller: Scroller = new Scroller();
  @Trace detailScroller: Scroller = new Scroller();
  @Trace commentScroller: Scroller = new Scroller();

  async loadData() {
    LogUtil.debug(TAG, JSON.stringify(this.tieSummary))
  }
}