import { BaseVM, WaterApi, WaterModels } from 'base_common';
import { CustomTabItem, LongTakeAnimationProperties } from 'base_ui';

@ObservedV2
export class WaterVM extends BaseVM {
  @Trace longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @Trace water: WaterModels = new WaterModels();
  @Trace isShowWaterDetailSheet: boolean = false;
  @Trace tabItems: CustomTabItem[] = [];

  async loadData() {
    this.water = await WaterApi.getWaterSummary();
  }
}