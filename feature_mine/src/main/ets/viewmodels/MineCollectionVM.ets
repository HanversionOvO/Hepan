import { LogUtil } from '@pura/harmony-utils';
import { curves } from '@kit.ArkUI';
import {
  BaseVM,
  BreakpointNameEnum,
  BreakpointType,
  Collection,
  CollectionUser,
  CommonConstant,
  DateUtil,
  RouterMap,
  RouterUtil,
  UiState,
  UserApi,
  UserFavoriteCollection
} from 'base_common';
import {
  LoneTakeAnimationsTransition,
  LongTakeTransitionParam
} from 'base_ui';
import { LongTakeTransitionOptions } from 'base_ui/src/main/ets/transitions/longtake/utils/Options';

const TAG = '[MineCollectionVM]: ';

@ObservedV2
export class MineCollectionVM extends BaseVM {
  @Trace collections: Collection[] = [];
  @Trace isRefreshing: boolean = false;
  @Trace pageScale: number = 1.0;
  @Trace columns: number = 2;
  @Trace minColumns: number = 1;
  @Trace maxColumns: number = 2;
  @Trace isScaling: boolean = false;

  private page: number = 1;
  private uid: number | 'me' = 'me';
  private isLoading: boolean = false;
  private hasLoaded: boolean = false;

  private defaultColumnsConfig: BreakpointType<number> = new BreakpointType<number>({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 4
  });
  private minColumnsConfig: BreakpointType<number> = new BreakpointType<number>({
    sm: 1,
    md: 1,
    lg: 2,
    xl: 3
  });
  private maxColumnsConfig: BreakpointType<number> = new BreakpointType<number>({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 4
  });

  @Monitor("breakPoint.currentBreakPoint")
  onBreakpointChange(): void {
    this.updateGridConfigFromBreakpoint(this.breakPoint.currentBreakPoint);
  }

  init(uid: number | 'me'): void {
    if (this.uid === uid && this.hasLoaded) {
      return;
    }
    this.uid = uid;
    this.reset();
  }

  ensureLoaded(): void {
    if (this.hasLoaded || this.isLoading) {
      return;
    }
    this.loadMineData(false);
  }

  updateGridConfigFromBreakpoint(bp: BreakpointNameEnum): void {
    this.columns = this.defaultColumnsConfig.getValue(bp);
    this.minColumns = this.minColumnsConfig.getValue(bp);
    this.maxColumns = this.maxColumnsConfig.getValue(bp);
  }

  getUniqueId(ctid: number): string {
    return `collection_${ctid}`;
  }

  async loadMineData(refresh: boolean): Promise<void> {
    if (this.isLoading) {
      return;
    }

    if (refresh) {
      this.page = 1;
      this.isRefreshing = true;
    }

    if (!refresh && this.collections.length === 0) {
      this.showLoading();
    }

    this.isLoading = true;
    try {
      await this.loadCollections(refresh);
    } catch (e) {
      LogUtil.error(TAG, `Load collections failed: ${JSON.stringify(e)}`);
      if (this.collections.length === 0) {
        this.showError();
      }
    } finally {
      this.isRefreshing = false;
      this.isLoading = false;
      this.hasLoaded = true;
    }
  }

  enterDetailPage(ctid: number, context: UIContext, collection: Collection): void {
    const uniqueId = this.getUniqueId(ctid);

    const options: LongTakeTransitionOptions = {
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

    const longTakeTransitionParam: LongTakeTransitionParam | undefined =
      LoneTakeAnimationsTransition.generateLongTakeParam(
        context,
        uniqueId,
        CommonConstant.RadiusLarge,
        options
      );

    const params: Record<string, Object> = {};
    if (longTakeTransitionParam) {
      params['transition'] = longTakeTransitionParam;
    }
    params['collection'] = collection;

    RouterUtil.pushPathByName(RouterMap.COLLECTION_CONTENT_PAGE, params);
  }

  private reset(): void {
    this.page = 1;
    this.collections = [];
    this.isRefreshing = false;
    this.isLoading = false;
    this.hasLoaded = false;
    this.showLoading();
  }

  private async loadCollections(refresh: boolean): Promise<void> {
    if (this.uid !== 'me') {
      this.collections = [];
      this.setUiState(UiState.EMPTY);
      return;
    }

    const data = await UserApi.getUserFavorites(this.page, 1);
    const rows = this.mapCollections(data.collections || []);
    this.handleResult(rows, refresh);
  }

  private mapCollections(rows: UserFavoriteCollection[]): Collection[] {
    return rows.map((item: UserFavoriteCollection) => {
      const collection = new Collection();
      collection.ctid = item.collection_id || 0;
      collection.title = item.name || '';
      collection.collection_nums = item.threads || 0;
      collection.subscribe = item.follows || 0;
      collection.comment = item.comments || 0;
      collection.description = item.description || '';
      collection.lastUpdate = item.last_update ? DateUtil.getRelativeTime(item.last_update) : '';
      const creator = new CollectionUser();
      creator.uid = item.uid || 0;
      creator.username = item.username || '';
      collection.creator = creator;
      collection.tags = item.keyword ? item.keyword.split(/[\s,，]+/).filter(Boolean) : [];
      return collection;
    });
  }

  private handleResult(rows: Collection[], refresh: boolean): void {
    const nextList = refresh ? [...rows] : [...this.collections, ...rows];
    this.collections = nextList;
    this.setUiStateByList(this.collections);
    if (rows.length > 0) {
      this.page += 1;
    }
  }
}
