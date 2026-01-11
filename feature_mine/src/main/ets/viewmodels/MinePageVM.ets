// feature_mine/src/main/ets/viewmodels/MinePageVM.ets
import { LogUtil } from '@pura/harmony-utils';
import {
  BaseVM,
  BreakpointType,
  CommonConstant,
  createEmptyUserProfileData,
  DateUtil,
  ForumTieSummary,
  Medal,
  RouterMap,
  RouterUtil,
  UiState,
  UserApi,
  UserProfileData
} from 'base_common';
import { FeatureCardModel } from '../components/FeatureCard';
import { UserProfileMapping, UserProfileSheetItem } from '../components/UserProfileSheet';
import { UserStatsModel } from '../components/UserStats';
import {
  CustomTabItem, LoneTakeAnimationsTransition, LongTakeTransitionParam
} from 'base_ui';
import { LongTakeTransitionOptions } from 'base_ui/src/main/ets/transitions/longtake/utils/Options';
import { curves } from '@kit.ArkUI';

const TAG = '[MinePageVM]: '

/**
 * 独立的 Tab ViewModel，负责管理单个 Tab 的列表数据和动画状态
 */
@ObservedV2
export class MineTabVM extends BaseVM {
  // 列表数据
  @Trace list: ForumTieSummary[] = [];
  @Trace state: UiState = UiState.LOADING;
  @Trace isRefreshing: boolean = false;
  // 页面缩放状态 (每个 Tab 独立管理)
  @Trace pageScale: number = 1.0;
  // 瀑布流列数
  @Trace columns: number = 2;
  @Trace minColumns: number = 1;
  @Trace maxColumns: number = 2;
  @Trace isScaling: boolean = false;
  private page: number = 1;
  private uid: number | 'me' = 'me';
  private tabType: 'thread' | 'reply' | 'fav';
  private user: UserProfileData = createEmptyUserProfileData();

  constructor(tabType: 'thread' | 'reply' | 'fav') {
    super();
    this.tabType = tabType;
  }

  init(uid: number | 'me') {
    this.uid = uid;
  }

  updateUser(user: UserProfileData) {
    this.user = user;
  }

  updateGridConfig(columns: number, min: number, max: number) {
    this.columns = columns;
    this.minColumns = min;
    this.maxColumns = max;
  }

  getUniqueId(tid: number): string {
    return `${this.tabType}_${tid}`;
  }

  async loadMineData(refresh: boolean) {
    if (refresh) {
      this.page = 1;
      this.isRefreshing = true;
    }
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
        this.state = UiState.ERROR;
      }
    } finally {
      this.isRefreshing = false;
    }
  }

  private async loadThreads(refresh: boolean) {
    const data = await UserApi.getUserThreads(this.page, this.uid);
    const rows = data.rows as ForumTieSummary[];
    this.handleResult(rows, refresh);
  }

  private async loadReplies(refresh: boolean) {
    const data = await UserApi.getUserReplies(this.page, this.uid);
    const mappedReplies: ForumTieSummary[] = (data.rows).map(reply => {
      return {
        thread_id: reply.thread_id,
        forum_id: reply.forum_id,
        type_id: 0,
        author: reply.author || '',
        author_id: reply.author_id || 0,
        subject: reply.subject,
        summary: reply.summary,
        dateline: reply.dateline,
        last_post: reply.last_post,
        views: reply.views,
        replies: reply.replies,
        forum_name: reply.forum_name
      } as ForumTieSummary;
    });
    this.handleResult(mappedReplies, refresh);
  }

  private async loadFavorites(refresh: boolean) {
    if (this.uid !== 'me') {
      this.state = UiState.EMPTY;
      return;
    }
    const data = await UserApi.getUserFavorites(this.page);
    const mappedFavs: ForumTieSummary[] = (data.rows).map(fav => fav.thread_details);
    this.handleResult(mappedFavs, refresh);
  }

  private handleResult(rows: ForumTieSummary[], refresh: boolean) {
    if (refresh) {
      this.list = rows;
      this.state = this.list.length === 0 ? UiState.EMPTY : UiState.SUCCESS;
    } else {
      this.list.push(...rows);
    }
    if (rows.length > 0) {
      this.page++;
    }
  }

  enterDetailPage(tid: number, context: UIContext, tieSummary: ForumTieSummary) {
    const uniqueId = this.getUniqueId(tid);

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
        uniqueId, CommonConstant.RadiusLarge, options);

    const params: Record<string, Object> = {};
    if (longTakeTransitionParam) {
      params["transition"] = longTakeTransitionParam;
    }
    params["tieSummary"] = tieSummary;

    RouterUtil.pushPathByName(RouterMap.TIE_CONTENT_PAGE, params);
  }
}

@ObservedV2
export class MinePageVM extends BaseVM {
  // === 基础状态 ===
  @Trace outerScrollScroller: Scroller = new Scroller();
  @Trace userPostTabController: TabsController = new TabsController();
  // 控制 StickyNavBar 的显示 (Opacity)
  @Trace navBarOpacity: number = 0;
  // 控制 TabBar 的 Glass 效果
  @Trace isTabBarGlass: boolean = false;
  @Trace isShowSignatureSheet: boolean = false;
  @Trace isShowUserProfileSheet: boolean = false;
  @Trace isShowMedalSheet: boolean = false;
  @Trace allMedals: Medal[] = [];
  // 全局刷新状态
  @Trace isRefreshing: boolean = false;
  @Trace user: UserProfileData = createEmptyUserProfileData();
  @Trace userStats: UserStatsModel[] = [];
  @Trace featureCards: FeatureCardModel[] = [];
  // === 子 ViewModel ===
  @Trace threadVM: MineTabVM = new MineTabVM('thread');
  @Trace replyVM: MineTabVM = new MineTabVM('reply');
  @Trace favVM: MineTabVM = new MineTabVM('fav');
  @Trace userPostTabItems: CustomTabItem[] = [
    { label: $r('app.string.MinePage_mine_post'), icon: $r('sys.symbol.book_closed_right_left') },
    { label: $r('app.string.MinePage_mine_reply'), icon: $r('sys.symbol.message') },
    { label: $r('app.string.MinePage_mine_star'), icon: $r('sys.symbol.star') },
  ]
  @Trace currentUserPostTabIndex: number = 0;
  @Trace uid: number | 'me' = 'me';
  // 瀑布流布局配置
  private defaultColumnsConfig = new BreakpointType({
    sm: 2,
    md: 3,
    lg: 4,
    xl: 5
  });
  private minColumnsConfig = new BreakpointType({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 4
  });
  private maxColumnsConfig = new BreakpointType({
    sm: 2,
    md: 4,
    lg: 5,
    xl: 6
  });

  @Computed
  get isMe(): boolean {
    return this.uid === 'me';
  }

  @Computed
  get currentTabVM(): MineTabVM {
    if (this.currentUserPostTabIndex === 1) {
      return this.replyVM;
    }
    if (this.currentUserPostTabIndex === 2) {
      return this.favVM;
    }
    return this.threadVM;
  }

  @Monitor("breakPoint.currentBreakPoint")
  onBreakpointChange() {
    const cols = this.defaultColumnsConfig.getValue(this.breakPoint.currentBreakPoint);
    const min = this.minColumnsConfig.getValue(this.breakPoint.currentBreakPoint);
    const max = this.maxColumnsConfig.getValue(this.breakPoint.currentBreakPoint);

    this.threadVM.updateGridConfig(cols, min, max);
    this.replyVM.updateGridConfig(cols, min, max);
    this.favVM.updateGridConfig(cols, min, max);
  }

  init(uid: number | 'me') {
    this.uid = uid;
    this.threadVM.init(uid);
    this.replyVM.init(uid);
    this.favVM.init(uid);
  }

  async startMine() {
    this.onBreakpointChange();
    await this.onRefreshAll();
  }

  // === 统一刷新入口 ===
  async onRefreshAll() {
    this.isRefreshing = true;
    try {
      await Promise.all([
        this.refreshData(),
        this.currentTabVM.loadMineData(true)
      ]);
    } catch (e) {
      LogUtil.error(TAG, 'Refresh all failed: ' + JSON.stringify(e));
    } finally {
      this.isRefreshing = false;
    }
  }

  async refreshData() {
    try {
      const fullProfile = await UserApi.getFullUserProfile(this.uid);
      if (fullProfile && fullProfile.user_summary) {
        this.user = fullProfile;
        this.threadVM.updateUser(fullProfile);
        this.replyVM.updateUser(fullProfile);
        this.favVM.updateUser(fullProfile);

        this.refreshDisplayData();
        LogUtil.info(TAG, `Full profile fetched. UID: ${fullProfile.user_summary.uid}`);
      }
    } catch (error) {
      LogUtil.error(TAG, 'Failed to fetch full user profile.', JSON.stringify(error));
    }
  }

  changeUserPostTab(index: number) {
    this.currentUserPostTabIndex = index;
    const targetVM = this.currentTabVM;
    if (targetVM.state === UiState.LOADING && !targetVM.isRefreshing) {
      targetVM.loadMineData(true);
    }
  }

  async loadMedals() {
    if (this.allMedals.length > 0) {
      return;
    }
    try {
      this.allMedals = await UserApi.getMedals();
    } catch (error) {
      LogUtil.error(TAG, 'Failed to load medals', JSON.stringify(error));
    }
  }

  private refreshDisplayData() {
    this.userStats = [];
    this.featureCards = [];
    const summary = this.user?.user_summary;
    if (this.user && summary) {
      this.userStats.push({
        label: $r("app.string.MinePage_friends"),
        count: summary.friends,
        onClick: () => {
          RouterUtil.pushPathByName(RouterMap.FANS, { "tab": "fan", "uid": this.uid } as Record<string, Object>);
        }
      });
      this.userStats.push({
        label: $r("app.string.MinePage_views"),
        count: summary.views,
        onClick: () => {
          RouterUtil.pushPathByName(RouterMap.FANS, { "tab": "visitor", "uid": this.uid } as Record<string, Object>);
        }
      });
      this.userStats.push({
        label: $r("app.string.MinePage_online_time"),
        count: this.user.online_time
      })

      this.featureCards.push({
        cardIcon: $r('sys.symbol.drop_fill'),
        cardTitle: $r('app.string.MinePage_water'),
        cardCount: summary.ext_credits["水滴"],
      });
      this.featureCards.push({
        cardIcon: $r('sys.symbol.medal'),
        cardTitle: $r('app.string.MinePage_medal'),
        cardCount: summary.medals?.length ?? 0,
        onClick: () => {
          this.isShowMedalSheet = true;
          this.loadMedals();
        }
      });
    }
  }

  async editSignature(signature: ResourceStr) {
    if (!this.isMe || !signature) {
      this.isShowSignatureSheet = false;
      return;
    }
    const result: boolean = await UserApi.editSignature(signature.toString());
    if (result) {
      this.isShowSignatureSheet = false;
      this.refreshData();
    }
  }

  getFilteredUserProfile(): UserProfileSheetItem[] {
    const list: UserProfileSheetItem[] = [];
    const user = this.user;
    const summary = user?.user_summary;
    if (!user || !summary) {
      return list;
    }

    const mapping: UserProfileMapping[] = [
      { val: summary.uid, suffix: 'uid', isDate: false },
      { val: summary.username, suffix: 'username', isDate: false },
      { val: summary.group_title, suffix: 'group_title', isDate: false },
      { val: summary.credits, suffix: 'credits', isDate: false },
      { val: summary.friends, suffix: 'friends', isDate: false },
      { val: summary.threads, suffix: 'threads', isDate: false },
      { val: summary.replies, suffix: 'replies', isDate: false },
      { val: summary.digests, suffix: 'digests', isDate: false },
      { val: summary.views, suffix: 'views', isDate: false },
      { val: user.email, suffix: 'email', isDate: false },
      { val: user.register_time, suffix: 'register_time', isDate: true },
      { val: user.introduction, suffix: 'introduction', isDate: false },
      { val: user.custom_title, suffix: 'custom_title', isDate: false },
      { val: user.signature, suffix: 'signature', isDate: false },
      { val: user.online_time, suffix: 'online_time', isDate: false },
      { val: user.last_visit, suffix: 'last_visit', isDate: true },
      { val: user.last_activity, suffix: 'last_activity', isDate: true },
      { val: user.last_post, suffix: 'last_post', isDate: true },
      { val: user.register_ip, suffix: 'register_ip', isDate: false },
      { val: user.last_ip, suffix: 'last_ip', isDate: false }
    ];

    mapping.forEach(item => {
      const value = item.val;
      if (value !== null && value !== undefined && value !== '') {
        let displayValue: string | number = value;
        if (item.isDate && typeof value === 'number') {
          displayValue = DateUtil.getRelativeTime(value);
        }
        list.push({
          title: $r(`app.string.MinePage_userprofile_${item.suffix}`),
          value: displayValue
        });
      }
    });
    return list;
  }
}
