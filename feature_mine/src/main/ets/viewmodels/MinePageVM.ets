import { LogUtil } from '@pura/harmony-utils';
import {
  BaseVM,
  BreakpointType,
  createEmptyUserProfileData,
  DateUtil,
  Medal,
  RouterMap,
  RouterUtil,
  ToastUtil,
  UserApi,
  UserProfileData
} from 'base_common';
import { FeatureCardModel } from '../components/FeatureCard';
import { UserProfileMapping, UserProfileSheetItem } from '../components/UserProfileSheet';
import { UserStatsModel } from '../components/UserStats';
import { CustomTabItem } from 'base_ui';
import { MineCollectionVM } from './MineCollectionVM';
import { MineTabVM } from './MineTabVM';

const TAG = '[MinePageVM]: ';

@ObservedV2
export class MinePageVM extends BaseVM {
  @Trace outerScrollScroller: Scroller = new Scroller();
  @Trace userPostTabController: TabsController = new TabsController();
  @Trace navBarOpacity: number = 0;
  @Trace isTabBarGlass: boolean = false;
  @Trace isShowSignatureSheet: boolean = false;
  @Trace isShowUserProfileSheet: boolean = false;
  @Trace isShowMedalSheet: boolean = false;
  @Trace allMedals: Medal[] = [];
  @Trace isRefreshing: boolean = false;
  @Trace user: UserProfileData = createEmptyUserProfileData();
  @Trace userStats: UserStatsModel[] = [];
  @Trace featureCards: FeatureCardModel[] = [];
  @Trace threadVM: MineTabVM = new MineTabVM('thread');
  @Trace replyVM: MineTabVM = new MineTabVM('reply');
  @Trace favVM: MineTabVM = new MineTabVM('fav');
  @Trace collectionVM: MineCollectionVM = new MineCollectionVM();
  readonly userPostTabItems: CustomTabItem[] = [
    { label: $r('app.string.MinePage_mine_post'), icon: $r('sys.symbol.book_closed_right_left') },
    { label: $r('app.string.MinePage_mine_reply'), icon: $r('sys.symbol.message') },
    { label: $r('app.string.MinePage_mine_star'), icon: $r('sys.symbol.star') },
    { label: $r('app.string.MinePage_mine_collection'), icon: $r('sys.symbol.folder') }
  ];
  @Trace currentUserPostTabIndex: number = 0;
  @Trace uid: number | 'me' = 'me';
  private defaultColumnsConfig: BreakpointType<number> = new BreakpointType<number>({
    sm: 2,
    md: 3,
    lg: 4,
    xl: 5
  });
  private minColumnsConfig: BreakpointType<number> = new BreakpointType<number>({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 4
  });
  private maxColumnsConfig: BreakpointType<number> = new BreakpointType<number>({
    sm: 2,
    md: 4,
    lg: 5,
    xl: 6
  });
  private initialized: boolean = false;
  private isLoadingBase: boolean = false;
  private isLoadingMedals: boolean = false;
  private hasLoadedProfile: boolean = false;

  @Computed
  get isMe(): boolean {
    return this.uid === 'me';
  }

  @Computed
  get currentTabVM(): MineTabVM | MineCollectionVM {
    if (this.currentUserPostTabIndex === 1) {
      return this.replyVM;
    }
    if (this.currentUserPostTabIndex === 2) {
      return this.favVM;
    }
    if (this.currentUserPostTabIndex === 3) {
      return this.collectionVM;
    }
    return this.threadVM;
  }

  @Monitor("breakPoint.currentBreakPoint")
  onBreakpointChange(): void {
    const cols: number = this.defaultColumnsConfig.getValue(this.breakPoint.currentBreakPoint);
    const min: number = this.minColumnsConfig.getValue(this.breakPoint.currentBreakPoint);
    const max: number = this.maxColumnsConfig.getValue(this.breakPoint.currentBreakPoint);

    this.threadVM.updateGridConfig(cols, min, max);
    this.replyVM.updateGridConfig(cols, min, max);
    this.favVM.updateGridConfig(cols, min, max);
    this.collectionVM.updateGridConfigFromBreakpoint(this.breakPoint.currentBreakPoint);
  }

  init(uid: number | 'me'): void {
    const isSameUser = this.initialized && this.uid === uid;
    this.uid = uid;
    this.initialized = true;

    this.threadVM.init(uid);
    this.replyVM.init(uid);
    this.favVM.init(uid);
    this.collectionVM.init(uid);

    if (!isSameUser) {
      this.currentUserPostTabIndex = 0;
      this.navBarOpacity = 0;
      this.isTabBarGlass = false;
      this.resetUserData();
    }
  }

  async startMine(): Promise<void> {
    if (this.isLoadingBase) {
      return;
    }
    this.onBreakpointChange();
    await this.loadInitialData();
  }

  async onRefreshAll(): Promise<void> {
    if (this.isRefreshing) {
      return;
    }
    this.isRefreshing = true;
    try {
      await Promise.all([
        this.loadUserProfile(),
        this.currentTabVM.loadMineData(true)
      ]);
    } catch (e) {
      LogUtil.error(TAG, 'Refresh all failed: ' + JSON.stringify(e));
    } finally {
      this.isRefreshing = false;
    }
  }

  private async loadInitialData(): Promise<void> {
    if (this.isLoadingBase) {
      return;
    }
    if (this.hasLoadedProfile) {
      return;
    }
    this.isLoadingBase = true;
    try {
      await this.loadUserProfile();
    } finally {
      this.isLoadingBase = false;
    }
  }

  private async loadUserProfile(): Promise<void> {
    try {
      const fullProfile = await UserApi.getFullUserProfile(this.uid);
      if (fullProfile && fullProfile.user_summary) {
        this.user = fullProfile;
        this.refreshDisplayData();
        this.hasLoadedProfile = true;
        LogUtil.info(TAG, `Full profile fetched. UID: ${fullProfile.user_summary.uid}`);
      }
    } catch (error) {
      LogUtil.error(TAG, 'Failed to fetch full user profile.', JSON.stringify(error));
    }
  }

  changeUserPostTab(index: number): void {
    if (index < 0 || index > 3 || this.currentUserPostTabIndex === index) {
      return;
    }
    this.currentUserPostTabIndex = index;
    this.currentTabVM.ensureLoaded();
  }

  async loadMedals(): Promise<void> {
    if (this.allMedals.length > 0 || this.isLoadingMedals) {
      return;
    }
    this.isLoadingMedals = true;
    try {
      this.allMedals = await UserApi.getMedals();
    } catch (error) {
      LogUtil.error(TAG, 'Failed to load medals', JSON.stringify(error));
    } finally {
      this.isLoadingMedals = false;
    }
  }

  private resetUserData(): void {
    this.user = createEmptyUserProfileData();
    this.userStats = [];
    this.featureCards = [];
    this.hasLoadedProfile = false;
  }

  private refreshDisplayData(): void {
    const summary = this.user?.user_summary;
    if (!summary) {
      this.userStats = [];
      this.featureCards = [];
      return;
    }

    const stats: UserStatsModel[] = [];
    stats.push(this.createUserStat(
      $r('app.string.MinePage_friends'),
      summary.friends,
      () => {
        RouterUtil.pushPathByName(RouterMap.FANS, { 'tab': 'fan', 'uid': this.uid } as Record<string, Object>);
      }
    ));
    stats.push(this.createUserStat(
      $r('app.string.MinePage_views'),
      summary.views,
      () => {
        RouterUtil.pushPathByName(RouterMap.FANS, { 'tab': 'visitor', 'uid': this.uid } as Record<string, Object>);
      }
    ));
    stats.push(this.createUserStat(
      $r('app.string.MinePage_online_time'),
      this.user?.online_time ?? 0
    ));
    this.userStats = stats;

    const credits = summary.ext_credits || {};
    const cards: FeatureCardModel[] = [
      {
        cardIcon: $r('sys.symbol.drop_fill'),
        cardTitle: $r('app.string.MinePage_water'),
        cardCount: credits['水滴'] ?? 0
      },
      {
        cardIcon: $r('sys.symbol.medal'),
        cardTitle: $r('app.string.MinePage_medal'),
        cardCount: summary.medals?.length ?? 0,
        onClick: () => {
          this.isShowMedalSheet = true;
          this.loadMedals();
        }
      }
    ];
    this.featureCards = cards;
  }

  private createUserStat(label: ResourceStr, count: number, onClick?: () => void): UserStatsModel {
    const model = new UserStatsModel();
    model.label = label;
    model.count = count;
    model.onClick = onClick;
    return model;
  }

  async editSignature(signature: ResourceStr): Promise<void> {
    if (!this.isMe || !signature) {
      this.isShowSignatureSheet = false;
      return;
    }
    const result: boolean = await UserApi.editSignature(signature.toString());
    if (result) {
      this.isShowSignatureSheet = false;
      await this.loadUserProfile();
      ToastUtil.showLightSuccess($r('app.string.MinePage_change_sig_success'))
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
