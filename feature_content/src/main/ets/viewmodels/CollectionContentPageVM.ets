import {
  BaseVM,
  BreakpointNameEnum,
  BreakpointType,
  Collection,
  CollectionApi,
  CollectionDetail,
  CollectionFollowResult,
  CollectionRemoveResult,
  CommonConstant,
  ForumDetailResponse,
  ForumTieSummary,
  RouterMap,
  RouterUtil,
  SummaryAttachments,
  ToastUtil,
  UiState
} from 'base_common';
import {
  LoneTakeAnimationsTransition,
  LongTakeAnimationProperties,
  LongTakeTransitionParam,
  NavTitleButtonModel
} from 'base_ui';
import { LongTakeTransitionOptions } from 'base_ui/src/main/ets/transitions/longtake/utils/Options';
import { curves } from '@kit.ArkUI';
import { LogUtil, ResUtil } from '@pura/harmony-utils';

const TAG = '[CollectionContentPageVM]: ';

@ObservedV2
export class CollectionContentPageVM extends BaseVM {
  @Trace isCollectionRefreshing: boolean = false;
  @Trace longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @Trace collection: Collection = new Collection();
  @Trace collectionDetail: CollectionDetail = new CollectionDetail();
  @Trace isSticky: boolean = false;
  @Trace isScaling: boolean = false;
  @Trace titleButtons: NavTitleButtonModel[] = [];
  @Trace outerPageScroller: Scroller = new Scroller();
  @Trace detailScroller: Scroller = new Scroller();
  @Trace tieScroller: Scroller = new Scroller();
  @Trace isReachEnd: boolean = false;
  @Trace pageScale: number = 1.0;
  @Trace ties: ForumTieSummary[] = [];
  @Trace tieLoadingState: UiState = UiState.LOADING;
  @Trace page: number = 1;
  @Trace hasMore: boolean = true;
  @Trace columns: number = 2;
  @Trace minColumns: number = 1;
  @Trace maxColumns: number = 3;
  private defaultColumnsConfig = new BreakpointType({
    sm: 2,
    md: 2,
    lg: 3,
    xl: 4
  });
  private minColumnsConfig = new BreakpointType({
    sm: 1,
    md: 1,
    lg: 2,
    xl: 4
  });
  private maxColumnsConfig = new BreakpointType({
    sm: 2,
    md: 2,
    lg: 3,
    xl: 5
  });

  updateGridConfig(bp: BreakpointNameEnum) {
    this.columns = this.defaultColumnsConfig.getValue(bp);
    this.minColumns = this.minColumnsConfig.getValue(bp);
    this.maxColumns = this.maxColumnsConfig.getValue(bp);
  }

  async loadData() {
    if (this.collection) {
      try {
        this.tieLoadingState = UiState.LOADING;

        this.collectionDetail = await CollectionApi.getCollectionDetail(this.collection.ctid);
        this.updateTitleButtons();

        const detailTies = this.collectionDetail.ties || [];
        const newTies = detailTies.map(t => this.convertDetailToSummary(t));

        if (newTies.length > 0) {
          this.ties = newTies;
          this.page = 2;
          this.hasMore = true;
          this.tieLoadingState = UiState.SUCCESS;
        } else {
          this.ties = [];
          this.hasMore = false;
          this.tieLoadingState = UiState.EMPTY;
        }

        this.updateGridConfig(this.breakPoint.currentBreakPoint);
      } catch (e) {
        LogUtil.error(TAG, "Load data error", e);
        this.tieLoadingState = UiState.ERROR;
      } finally {
        this.isCollectionRefreshing = false;
      }
    }
  }

  /**
   * 加载专辑内的帖子列表
   * @param isRefresh 是否为刷新/重新加载
   */
  async loadTies(isRefresh: boolean) {
    if (!this.collection) {
      return;
    }

    if (isRefresh) {
      this.page = 1;
      this.hasMore = true;
      this.tieLoadingState = UiState.LOADING;
      this.ties = [];
    }

    if (!this.hasMore) {
      return;
    }

    try {
      // 获取详情（带分页）
      const detail = await CollectionApi.getCollectionDetail(this.collection.ctid, this.page);
      if (this.page === 1) {
        this.collectionDetail.canDelete = detail.canDelete;
        this.collectionDetail.deleteFormhash = detail.deleteFormhash;
        this.updateTitleButtons();
      }

      // 将详情数据转换为摘要数据
      const newTies = detail.ties?.map(t => this.convertDetailToSummary(t)) || [];

      if (newTies.length > 0) {
        if (isRefresh) {
          this.ties = newTies;
        } else {
          this.ties.push(...newTies);
        }
        this.page++;
      } else {
        this.hasMore = false;
      }

      if (this.ties.length === 0) {
        this.tieLoadingState = UiState.EMPTY;
      } else {
        this.tieLoadingState = UiState.SUCCESS;
      }

    } catch (e) {
      LogUtil.error(TAG, "Load ties error", e);
      if (this.ties.length === 0) {
        this.tieLoadingState = UiState.ERROR;
      }
    } finally {
      this.isCollectionRefreshing = false; // 停止下拉刷新动画
    }
  }

  private updateTitleButtons(): void {
    const buttons: NavTitleButtonModel[] = [];
    if (this.collectionDetail?.canDelete) {
      buttons.push({
        icon: $r('sys.symbol.trash'),
        onClick: () => {
          const title = this.collection?.title?.trim();
          const message =
            title ? `${ResUtil.getStringSync($r('app.string.CollectionPage_is_delete'))} ${title}` : '是否删除该淘专辑';
          ToastUtil.showWarn(message, true, undefined, () => {
            this.removeCollection();
          });
        }
      });
    }
    this.titleButtons = buttons;
  }

  private async removeCollection(): Promise<void> {
    const formhash = this.collectionDetail.deleteFormhash || this.collectionDetail.formhash;
    if (!formhash) {
      return;
    }

    const result: CollectionRemoveResult = await CollectionApi.removeCollection(this.collection.ctid, formhash);
    if (result.success) {
      ToastUtil.showLightSuccess(`${ResUtil.getStringSync($r('app.string.CollectionPage_delete_success'))}${this.collection.title}`);
      RouterUtil.pop();
    } else if (result.message) {
      ToastUtil.showLightError(result.message);
    }
  }

  /**
   * 将帖子详情响应转换为帖子摘要 (用于 TieCard 展示)
   */
  private convertDetailToSummary(detail: ForumDetailResponse): ForumTieSummary {
    const topic = detail.topic;

    // 提取图片附件
    let attachments: SummaryAttachments[] = [];
    if (topic.content && topic.content.length > 0) {
      topic.content.forEach(c => {
        // 假设 type 1 或有 url 的是图片，根据具体业务调整
        if (c.type === 1 && c.infor) {
          attachments.push({
            is_image: 1,
            thumbnail_url: c.infor,
            raw_url: c.url,
            attachment_id: 0,
            dateline: 0,
            filename: '',
            size: 0,
            path: '',
            description: '',
            price: 0,
            width: 0,
            thumb: true,
            picid: 0
          } as SummaryAttachments);
        }
      });
    }

    // 解析时间
    let dateline = 0;
    try {
      // 【修复】增强时间解析的兼容性
      let dateStr = topic.create_date;
      if (dateStr) {
        // 将 - 替换为 /，解决部分环境 new Date 解析失败问题
        dateStr = dateStr.replace(/-/g, '/');
        const ts = new Date(dateStr).getTime();
        if (!isNaN(ts)) {
          dateline = ts / 1000;
        }
      }
    } catch (e) {
      LogUtil.error(TAG, 'Parse time error', e);
    }

    // 提取文本摘要
    let summary = '';
    const textContent = topic.content.find(c => c.type === 0 || c.infor);
    if (textContent) {
      summary = textContent.infor;
    }

    return {
      thread_id: topic.topic_id,
      forum_id: detail.boardId,
      type_id: 0,
      author: topic.user_nick_name,
      author_id: topic.user_id,
      subject: topic.title,
      summary: summary,
      summary_attachments: attachments,
      dateline: Number(topic.create_date),
      last_post: 0,
      views: topic.hits,
      replies: topic.replies,
      label: '',
      recommend_add: 0,
      recommend_sub: 0,
      display_order: 0,
      forum_name: detail.forumName
    };
  }

  enterDetailPage(componentId: string, context: UIContext, collection: Collection) {
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
        componentId, CommonConstant.RadiusLarge, options);

    const params: Record<string, Object> = {};

    if (longTakeTransitionParam) {
      let transitionParam: LongTakeTransitionParam = longTakeTransitionParam;
      params["transition"] = transitionParam;
    }

    params["collection"] = collection;

    RouterUtil.pushPathByName(RouterMap.COLLECTION_CONTENT_PAGE, params);
  }

  /**
   * 跳转到帖子详情页
   */
  enterTieDetailPage(componentId: string, context: UIContext, tie: ForumTieSummary) {
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
        componentId, CommonConstant.RadiusLarge, options);

    const params: Record<string, Object> = {};

    if (longTakeTransitionParam) {
      let transitionParam: LongTakeTransitionParam = longTakeTransitionParam;
      params["transition"] = transitionParam;
    }

    params["tieSummary"] = tie;

    RouterUtil.pushPathByName(RouterMap.TIE_CONTENT_PAGE, params);
  }

  handleScroll() {
    const yOffset = this.isTabletView
      ? this.detailScroller.currentOffset().yOffset
      : this.outerPageScroller.currentOffset().yOffset;

    const threshold = this.window.windowTopPadding + CommonConstant.TopBarHeight;

    const shouldBeSticky = yOffset > threshold;

    if (this.isSticky !== shouldBeSticky) {
      animateTo({ duration: CommonConstant.AnimationDurationNormal }, () => {
        this.isSticky = shouldBeSticky;
      })
    }
  }

  async toggleSubs() {
    if (this.collection && this.collectionDetail && (this.collectionDetail.isFollow !== undefined) &&
    this.collectionDetail.formhash) {
      const result: CollectionFollowResult =
        await CollectionApi.toggleFollow(this.collection.ctid, this.collectionDetail.isFollow,
          this.collectionDetail.formhash)

      if (result.success) {
        this.collectionDetail.isFollow = !this.collectionDetail.isFollow
      }
    }
  }
}
