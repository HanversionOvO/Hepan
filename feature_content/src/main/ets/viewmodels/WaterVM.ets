import { BaseVM, WaterApi, WaterModels } from 'base_common';
import { LongTakeAnimationProperties } from 'base_ui';

@ObservedV2
export class WaterVM extends BaseVM {
  @Trace longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @Trace water: WaterModels = new WaterModels();
  @Trace isShowWaterDetailSheet: boolean = false;

  async loadData() {
    this.water = await WaterApi.getWaterSummary();
  }
}