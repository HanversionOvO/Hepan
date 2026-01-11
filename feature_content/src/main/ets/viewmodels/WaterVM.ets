import {
  BaseVM,
  BreakpointNameEnum,
  BreakpointType,
  WaterApi,
  WaterMission,
  WaterMissionState,
  WaterModels
} from 'base_common';
import { CustomTabItem, LongTakeAnimationProperties } from 'base_ui';

@ObservedV2
export class WaterVM extends BaseVM {
  @Trace longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @Trace water: WaterModels = new WaterModels();
  @Trace currentIndex: number = 0;
  @Trace isShowWaterDetailSheet: boolean = false;
  @Trace isLoadingMore: boolean = false;
  @Trace isRefreshMission: boolean = false;
  @Trace currentPage: number = 1;
  @Trace columns: number = 2;
  @Trace tabItems: CustomTabItem[] = [
    { label: $r('app.string.WaterPage_get_water'), icon: $r('sys.symbol.light') },
    { label: $r('app.string.WaterPage_store'), icon: $r('sys.symbol.store') },
    { label: $r('app.string.WaterPage_backpack'), icon: $r('sys.symbol.card_package') },
    { label: $r('app.string.WaterPage_transfer'), icon: $r('sys.symbol.wallet') }
  ];

  @Monitor("breakPoint.currentBreakPoint")
  onBreakpointChange() {
    this.updateGridConfig(this.breakPoint.currentBreakPoint);
  }

  private defaultColumnsConfig = new BreakpointType({
    sm: 1,
    md: 2,
    lg: 2,
    xl: 3
  });

  updateGridConfig(bp: BreakpointNameEnum) {
    this.columns = this.defaultColumnsConfig.getValue(bp);
  }

  async loadData() {
    this.currentPage = 1;
    this.water = await WaterApi.getWaterSummary(1);
    this.updateGridConfig(this.breakPoint.currentBreakPoint);
  }

  async loadMore() {
    if (this.isLoadingMore) {
      return;
    }
    this.isLoadingMore = true;
    const nextPage = this.currentPage + 1;

    // 获取下一页数据
    const nextWaterModel = await WaterApi.getWaterSummary(nextPage);

    if (nextWaterModel.records.length > 0) {
      this.water.records.push(...nextWaterModel.records);
      this.currentPage = nextPage;
      this.water.water_nums = nextWaterModel.water_nums;
    }

    this.isLoadingMore = false;
  }

  async getMissions(): Promise<WaterMission[]> {
    const newMissions: WaterMission[] = await WaterApi.getWaterMission(WaterMissionState.NEW);
    const doingMissions: WaterMission[] = await WaterApi.getWaterMission(WaterMissionState.DOING);
    const finishMissions: WaterMission[] = await WaterApi.getWaterMission(WaterMissionState.FINISH);
    const failMissions: WaterMission[] = await WaterApi.getWaterMission(WaterMissionState.FAIL);

    this.isRefreshMission = false;

    return [...newMissions, ...doingMissions, ...finishMissions, ...failMissions];
  }

  changeTab(index: number) {
    this.currentIndex = index;
  }
}