import { BaseVM, WaterApi, WaterModels } from 'base_common';
import { CustomTabItem, LongTakeAnimationProperties } from 'base_ui';

@ObservedV2
export class WaterVM extends BaseVM {
  @Trace longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @Trace water: WaterModels = new WaterModels();
  @Trace isShowWaterDetailSheet: boolean = false;
  @Trace isLoadingMore: boolean = false;
  @Trace currentPage: number = 1;
  @Trace tabItems: CustomTabItem[] = [
    { label: $r('app.string.WaterPage_get_water'), icon: $r('sys.symbol.light') },
    { label: $r('app.string.WaterPage_store'), icon: $r('sys.symbol.store') },
    { label: $r('app.string.WaterPage_backpack'), icon: $r('sys.symbol.card_package') },
    { label: $r('app.string.WaterPage_transfer'), icon: $r('sys.symbol.wallet') }
  ];

  async loadData() {
    this.currentPage = 1;
    this.water = await WaterApi.getWaterSummary(1);
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
}