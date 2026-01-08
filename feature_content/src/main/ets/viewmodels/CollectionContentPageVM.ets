import { BaseVM, Collection, CollectionApi, CollectionDetail } from 'base_common';
import { LongTakeAnimationProperties, NavTitleButtonModel } from 'base_ui';

const TAG = '[CollectionContentPageVM]: ';

@ObservedV2
export class CollectionContentPageVM extends BaseVM {
  @Trace isCollectionRefreshing: boolean = false;
  @Trace longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @Trace collection: Collection | null = null;
  @Trace collectionDetail: CollectionDetail | null = null;
  @Trace isSticky: boolean = false;
  @Trace titleButtons: NavTitleButtonModel[] = [];
  @Trace outerPageScroller: Scroller = new Scroller();
  @Trace detailScroller: Scroller = new Scroller();
  @Trace tieScroller: Scroller = new Scroller();
  @Trace isReachEnd: boolean = false;

  async loadData() {
    if (this.collection) {
      this.collectionDetail = await CollectionApi.getCollectionDetail(this.collection.ctid);
    }
  }
}