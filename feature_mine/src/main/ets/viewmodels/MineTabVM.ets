import { LogUtil } from '@pura/harmony-utils';
import { curves } from '@kit.ArkUI';
import {
  BaseVM,
  CommonConstant,
  ForumTieSummary,
  RouterMap,
  RouterUtil,
  UiState,
  UserApi
} from 'base_common';
import {
  LoneTakeAnimationsTransition,
  LongTakeTransitionParam
} from 'base_ui';
import { LongTakeTransitionOptions } from 'base_ui/src/main/ets/transitions/longtake/utils/Options';

const TAG = '[MineTabVM]: ';

@ObservedV2
export class MineTabVM extends BaseVM {
  @Trace list: ForumTieSummary[] = [];
  @Trace isRefreshing: boolean = false;
  @Trace pageScale: number = 1.0;
  @Trace columns: number = 2;
  @Trace minColumns: number = 1;
  @Trace maxColumns: number = 2;
  @Trace isScaling: boolean = false;

  private page: number = 1;
  private uid: number | 'me' = 'me';
  private readonly tabType: 'thread' | 'reply' | 'fav';
  private isLoading: boolean = false;
  private hasLoaded: boolean = false;

  constructor(tabType: 'thread' | 'reply' | 'fav') {
    super();
    this.tabType = tabType;
    this.showLoading();
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

  updateGridConfig(columns: number, min: number, max: number): void {
    this.columns = columns;
    this.minColumns = min;
    this.maxColumns = max;
  }

  getUniqueId(tid: number): string {
    return `${this.tabType}_${tid}`;
  }

  async loadMineData(refresh: boolean): Promise<void> {
    if (this.isLoading) {
      return;
    }

    if (refresh) {
      this.page = 1;
      this.isRefreshing = true;
    }

    if (!refresh && this.list.length === 0) {
      this.showLoading();
    }

    this.isLoading = true;
    try {
      if (this.tabType === 'thread') {
        await this.loadThreads(refresh);
      } else if (this.tabType === 'reply') {
        await this.loadReplies(refresh);
      } else if (this.tabType === 'fav') {
        await this.loadFavorites(refresh);
      }
    } catch (e) {
      LogUtil.error(TAG, `Load ${this.tabType} failed: ${JSON.stringify(e)}`);
      if (this.list.length === 0) {
        this.showError();
      }
    } finally {
      this.isRefreshing = false;
      this.isLoading = false;
      this.hasLoaded = true;
    }
  }

  private reset(): void {
    this.page = 1;
    this.list = [];
    this.isRefreshing = false;
    this.isLoading = false;
    this.hasLoaded = false;
    this.showLoading();
  }

  private async loadThreads(refresh: boolean): Promise<void> {
    const data = await UserApi.getUserThreads(this.page, this.uid);
    const rows: ForumTieSummary[] = data.rows;
    this.handleResult(rows, refresh);
  }

  private async loadReplies(refresh: boolean): Promise<void> {
    const data = await UserApi.getUserReplies(this.page, this.uid);
    const mappedReplies: ForumTieSummary[] = data.rows.map((reply) => {
      const mapped = new ForumTieSummary();
      mapped.thread_id = reply.thread_id;
      mapped.forum_id = reply.forum_id;
      mapped.type_id = 0;
      mapped.author = reply.author || '';
      mapped.author_id = reply.author_id || 0;
      mapped.subject = reply.subject;
      mapped.summary = reply.summary;
      mapped.dateline = reply.dateline;
      mapped.last_post = reply.last_post;
      mapped.views = reply.views;
      mapped.replies = reply.replies;
      mapped.forum_name = reply.forum_name;
      return mapped;
    });
    this.handleResult(mappedReplies, refresh);
  }

  private async loadFavorites(refresh: boolean): Promise<void> {
    if (this.uid !== 'me') {
      this.list = [];
      this.setUiState(UiState.EMPTY);
      return;
    }
    const data = await UserApi.getUserFavorites(this.page, 0);
    const mappedFavs: ForumTieSummary[] = data.rows.map((fav) => fav.thread_details);
    this.handleResult(mappedFavs, refresh);
  }

  private handleResult(rows: ForumTieSummary[], refresh: boolean): void {
    const nextList = refresh ? [...rows] : [...this.list, ...rows];
    this.list = nextList;
    this.setUiStateByList(this.list);
    if (rows.length > 0) {
      this.page += 1;
    }
  }

  enterDetailPage(tid: number, context: UIContext, tieSummary: ForumTieSummary): void {
    const uniqueId = this.getUniqueId(tid);

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
    params['tieSummary'] = tieSummary;

    RouterUtil.pushPathByName(RouterMap.TIE_CONTENT_PAGE, params);
  }
}
