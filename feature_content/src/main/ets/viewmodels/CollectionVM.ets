import { LogUtil } from '@pura/harmony-utils';
import {
  BaseVM,
  BreakpointNameEnum,
  BreakpointType,
  Collection,
  CollectionApi,
  CollectionSortOrder
} from 'base_common';
import { CustomTabItem } from 'base_ui';

const TAG = '[CollectionVM]: ';

@ObservedV2
export class CollectionVM extends BaseVM {
  @Trace sortTabItems: CustomTabItem[] = [
    { label: $r('app.string.CollectionView_create_time'), icon: $r('sys.symbol.calendar') },
    { label: $r('app.string.CollectionView_topic'), icon: $r('sys.symbol.topic') },
    { label: $r('app.string.CollectionView_comment'), icon: $r('sys.symbol.message') },
    { label: $r('app.string.CollectionView_subs'), icon: $r('sys.symbol.pin') }
  ];
  @Trace collections: Collection[] = [];
  @Trace currentSort: CollectionSortOrder = CollectionSortOrder.DATE;
  @Trace currentSortIndex: number = 0;
  @Trace currentPage: number = 1;
  @Trace isRefreshing: boolean = false;
  @Trace columns: number = 2;
  @Trace minColumns: number = 1;
  @Trace maxColumns: number = 3;
  @Trace isScaling: boolean = false;

  @Monitor("breakPoint.currentBreakPoint")
  onBreakpointChange() {
    this.updateGridConfig(this.breakPoint.currentBreakPoint);
  }

  private defaultColumnsConfig = new BreakpointType({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 4
  });
  private minColumnsConfig = new BreakpointType({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 4
  });
  private maxColumnsConfig = new BreakpointType({
    sm: 1,
    md: 3,
    lg: 5,
    xl: 6
  });

  updateGridConfig(bp: BreakpointNameEnum) {
    this.columns = this.defaultColumnsConfig.getValue(bp);
    this.minColumns = this.minColumnsConfig.getValue(bp);
    this.maxColumns = this.maxColumnsConfig.getValue(bp);
  }

  async loadData() {
    this.collections = await CollectionApi.getCollections(this.currentPage, this.currentSort);
    this.updateGridConfig(this.breakPoint.currentBreakPoint);
    LogUtil.debug(TAG, JSON.stringify(this.collections));
  }
}