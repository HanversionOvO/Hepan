import { LogUtil } from '@pura/harmony-utils';
import {
  BaseVM,
  BreakpointNameEnum,
  BreakpointType,
  Collection,
  CollectionApi,
  CollectionSortOrder,
  CommonConstant,
  RouterMap,
  RouterUtil
} from 'base_common';
import { CustomTabItem, LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'base_ui';
import { LongTakeTransitionOptions } from 'base_ui/src/main/ets/transitions/longtake/utils/Options';
import { curves } from '@kit.ArkUI';

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
  @Trace isLoadingMore: boolean = false;
  @Trace columns: number = 2;
  @Trace minColumns: number = 1;
  @Trace maxColumns: number = 3;
  @Trace isScaling: boolean = false;
  @Trace pageScale: number = 1.0;

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
    md: 1,
    lg: 2,
    xl: 3
  });
  private maxColumnsConfig = new BreakpointType({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 4
  });

  updateGridConfig(bp: BreakpointNameEnum) {
    this.columns = this.defaultColumnsConfig.getValue(bp);
    this.minColumns = this.minColumnsConfig.getValue(bp);
    this.maxColumns = this.maxColumnsConfig.getValue(bp);
  }

  async loadData() {
    this.collections = await CollectionApi.getCollections(this.currentPage, this.currentSort);
    this.updateGridConfig(this.breakPoint.currentBreakPoint);
  }

  async refresh() {
    this.currentPage = 1;
    try {
      const data = await CollectionApi.getCollections(this.currentPage, this.currentSort);
      this.collections = data;
    } catch (e) {
      LogUtil.error(TAG, 'Refresh failed', JSON.stringify(e));
    } finally {
      this.isRefreshing = false;
    }
  }

  async loadMore() {
    if (this.isLoadingMore || this.isRefreshing) {
      return;
    }
    this.isLoadingMore = true;
    try {
      const nextPage = this.currentPage + 1;
      const data = await CollectionApi.getCollections(nextPage, this.currentSort);
      if (data && data.length > 0) {
        this.collections.push(...data);
        this.currentPage = nextPage;
      }
    } catch (e) {
      LogUtil.error(TAG, 'Load more failed', JSON.stringify(e));
    } finally {
      this.isLoadingMore = false;
    }
  }

  async changeSort(index: number) {
    if (this.currentSortIndex === index) {
      return;
    }
    this.currentSortIndex = index;
    switch (index) {
      case 0:
        this.currentSort = CollectionSortOrder.DATE;
        break;
      case 1:
        this.currentSort = CollectionSortOrder.THREAD_NUM;
        break;
      case 2:
        this.currentSort = CollectionSortOrder.COMMENT_NUM;
        break;
      case 3:
        this.currentSort = CollectionSortOrder.FOLLOW_NUM;
        break;
      default:
        this.currentSort = CollectionSortOrder.DATE;
        break;
    }
    this.isRefreshing = true;
    await this.refresh();
  }

  enterDetailPage(ctid: string, context: UIContext, collection: Collection) {
    let options: LongTakeTransitionOptions = {
      onEnterTransitionStart: () => {
        context.animateTo({ curve: curves.springMotion(0.35, 0.75) }, () => {
          this.pageScale = 0.8;
        })
      },
      onBackTransitionStart: () => {
        context.animateTo({ curve: curves.springMotion(0.35, 0.75) }, () => {
          this.pageScale = 1.0;
        })
      }
    };

    let longTakeTransitionParam: LongTakeTransitionParam | undefined =
      LoneTakeAnimationsTransition.generateLongTakeParam(context,
        ctid, CommonConstant.RadiusLarge, options);

    const params: Record<string, Object> = {};

    if (longTakeTransitionParam) {
      let transitionParam: LongTakeTransitionParam = longTakeTransitionParam;
      params["transition"] = transitionParam;
    }

    params["collection"] = collection;

    RouterUtil.pushPathByName(RouterMap.COLLECTION_CONTENT_PAGE, params);
  }
}