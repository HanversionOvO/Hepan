// feature_mine/src/main/ets/viewmodels/MinePageVM.ets
import { LogUtil } from '@pura/harmony-utils';
import {
  BaseVM,
  BreakpointNameEnum,
  BreakpointType,
  CommonConstant,
  DateUtil,
  ForumTieSummary,
  RouterMap,
  RouterUtil,
  UiState,
  UserApi
} from 'base_common';
import { Medal, UserProfileData } from 'base_common/src/main/ets/api/models/UserModels';
import { FeatureCardModel } from '../components/FeatureCard';
import { UserProfileMapping, UserProfileSheetItem } from '../components/UserProfileSheet';
import { UserStatsModel } from '../components/UserStats';
import {
  CustomTabItem, LoneTakeAnimationsTransition, LongTakeTransitionParam
} from 'base_ui';
import { LongTakeTransitionOptions } from 'base_ui/src/main/ets/transitions/longtake/utils/Options';
import { curves } from '@kit.ArkUI';

const TAG = '[MinePageVM]: '

@ObservedV2
export class MinePageVM extends BaseVM {
  // === 基础状态 ===
  @Trace outerScrollScroller: Scroller = new Scroller();
  @Trace userPostTabController: TabsController = new TabsController();
  @Trace isSticky: boolean = false;
  @Trace isTabBarGlass: boolean = false;
  @Trace isShowSignatureSheet: boolean = false;
  @Trace isShowUserProfileSheet: boolean = false;
  @Trace isShowMedalSheet: boolean = false;
  @Trace allMedals: Medal[] = [];
  @Trace isRefreshing: boolean = false;
  @Trace user: UserProfileData | null = null;
  @Trace userStats: UserStatsModel[] = [];
  @Trace featureCards: FeatureCardModel[] = [];
  // === Tab 配置 ===
  @Trace userPostTabItems: CustomTabItem[] = [
    { label: $r('app.string.MinePage_mine_post'), icon: $r('sys.symbol.book_closed_right_left') },
    { label: $r('app.string.MinePage_mine_reply'), icon: $r('sys.symbol.message') },
    { label: $r('app.string.MinePage_mine_star'), icon: $r('sys.symbol.star') },
  ]
  @Trace currentUserPostTabIndex: number = 0;
  @Trace uid: number | 'me' = 'me';
  // === 列表数据状态 ===
  @Trace threads: ForumTieSummary[] = [];
  @Trace threadsState: UiState = UiState.LOADING;
  @Trace isRefreshingThreads: boolean = false;
  private threadsPage: number = 1;
  @Trace replies: ForumTieSummary[] = [];
  @Trace repliesState: UiState = UiState.LOADING;
  @Trace isRefreshingReplies: boolean = false;
  private repliesPage: number = 1;
  @Trace favorites: ForumTieSummary[] = [];
  @Trace favoritesState: UiState = UiState.LOADING;
  @Trace isRefreshingFavorites: boolean = false;
  private favoritesPage: number = 1;
  // === 瀑布流布局配置 (与 TieVM 保持完全一致) ===
  @Trace columns: number = 2;
  @Trace minColumns: number = 1;
  @Trace maxColumns: number = 2; // 初始值设为2，会通过 updateGridConfig 更新
  @Trace isScaling: boolean = false;
  @Trace pageScale: number = 1.0;
  // 默认列数配置
  private defaultColumnsConfig = new BreakpointType({
    sm: 2,
    md: 3,
    lg: 4,
    xl: 5
  });
  // 最小列数配置
  private minColumnsConfig = new BreakpointType({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 4
  });
  // 最大列数配置 (关键：sm 限制为 2，与 TieVM 一致)
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

  // 监听断点变化
  @Monitor("breakPoint.currentBreakPoint")
  onBreakpointChange() {
    this.updateGridConfig(this.breakPoint.currentBreakPoint);
  }

  // 更新网格配置
  updateGridConfig(bp: BreakpointNameEnum) {
    this.columns = this.defaultColumnsConfig.getValue(bp);
    this.minColumns = this.minColumnsConfig.getValue(bp);
    this.maxColumns = this.maxColumnsConfig.getValue(bp);
  }

  init(uid: number | 'me') {
    this.uid = uid;
  }

  async startMine() {
    // 启动时初始化网格配置
    this.updateGridConfig(this.breakPoint.currentBreakPoint);
    await this.refreshData();
    this.loadTabContent(0, true);
  }

  async refreshData() {
    try {
      const fullProfile = await UserApi.getFullUserProfile(this.uid);
      if (fullProfile && fullProfile.user_summary) {
        this.user = fullProfile;
        this.refreshDisplayData();
        LogUtil.info(TAG, `Full profile fetched. UID: ${fullProfile.user_summary.uid}`);
      }
    } catch (error) {
      LogUtil.error(TAG, 'Failed to fetch full user profile.', JSON.stringify(error));
    } finally {
      this.isRefreshing = false;
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

  changeUserPostTab(index: number) {
    this.currentUserPostTabIndex = index;
    if (index === 0) {
      if (this.threadsState === UiState.LOADING && !this.isRefreshingThreads) {
        this.loadTabContent(0, true);
      }
    } else if (index === 1) {
      if (this.repliesState === UiState.LOADING && !this.isRefreshingReplies) {
        this.loadTabContent(1, true);
      }
    } else if (index === 2) {
      if (this.favoritesState === UiState.LOADING && !this.isRefreshingFavorites) {
        this.loadTabContent(2, true);
      }
    }
  }

  async loadTabContent(index: number, refresh: boolean) {
    if (index === 0) {
      await this.loadThreads(refresh);
    } else if (index ===
      1) {
      await this.loadReplies(refresh);
    } else if (index === 2) {
      await this.loadFavorites(refresh);
    }
  }

  async loadThreads(refresh: boolean) {
    if (refresh) {
      this.threadsPage = 1;
      this.isRefreshingThreads = true;
    }
    try {
      const data = await UserApi.getUserThreads(this.threadsPage, this.uid);
      const rows = data.rows;
      if (refresh) {
        this.threads = rows;
        this.threadsState = this.threads.length === 0 ? UiState.EMPTY : UiState.SUCCESS;
      } else {
        this.threads.push(...rows);
      }
      if (rows.length > 0) {
        this.threadsPage++;
      }
    } catch (e) {
      LogUtil.error(TAG, 'Load threads failed: ' + JSON.stringify(e));
      if (this.threads.length === 0) {
        this.threadsState = UiState.ERROR;
      }
    } finally {
      this.isRefreshingThreads = false;
    }
  }

  async loadReplies(refresh: boolean) {
    if (refresh) {
      this.repliesPage = 1;
      this.isRefreshingReplies = true;
    }
    try {
      const data = await UserApi.getUserReplies(this.repliesPage, this.uid);
      const mappedReplies: ForumTieSummary[] = (data.rows).map(reply => {
        return {
          thread_id: reply.thread_id,
          forum_id: reply.forum_id,
          type_id: 0,
          author: this.user?.user_summary?.username || '',
          author_id: this.user?.user_summary?.uid || 0,
          subject: reply.subject,
          summary: reply.summary,
          dateline: reply.dateline,
          last_post: reply.last_post,
          views: reply.views,
          replies: reply.replies,
          forum_name: reply.forum_name
        } as ForumTieSummary;
      });

      if (refresh) {
        this.replies = mappedReplies;
        this.repliesState = this.replies.length === 0 ? UiState.EMPTY : UiState.SUCCESS;
      } else {
        this.replies.push(...mappedReplies);
      }
      if (data.rows.length > 0) {
        this.repliesPage++;
      }
    } catch (e) {
      LogUtil.error(TAG, 'Load replies failed: ' + JSON.stringify(e));
      if (this.replies.length === 0) {
        this.repliesState = UiState.ERROR;
      }
    } finally {
      this.isRefreshingReplies = false;
    }
  }

  async loadFavorites(refresh: boolean) {
    if (!this.isMe) {
      this.favoritesState = UiState.EMPTY;
      return;
    }
    if (refresh) {
      this.favoritesPage = 1;
      this.isRefreshingFavorites = true;
    }
    try {
      const data = await UserApi.getUserFavorites(this.favoritesPage);
      const mappedFavs: ForumTieSummary[] = (data.rows).map(fav => fav.thread_details);

      if (refresh) {
        this.favorites = mappedFavs;
        this.favoritesState = this.favorites.length === 0 ? UiState.EMPTY : UiState.SUCCESS;
      } else {
        this.favorites.push(...mappedFavs);
      }
      if (data.rows.length > 0) {
        this.favoritesPage++;
      }
    } catch (e) {
      LogUtil.error(TAG, 'Load favorites failed: ' + JSON.stringify(e));
      if (this.favorites.length === 0) {
        this.favoritesState = UiState.ERROR;
      }
    } finally {
      this.isRefreshingFavorites = false;
    }
  }

  enterDetailPage(tid: string, context: UIContext, tieSummary: ForumTieSummary) {
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
        tid, CommonConstant.RadiusLarge, options);

    const params: Record<string, Object> = {};
    if (longTakeTransitionParam) {
      params["transition"] = longTakeTransitionParam;
    }
    params["tieSummary"] = tieSummary;

    RouterUtil.pushPathByName(RouterMap.TIE_CONTENT_PAGE, params);
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