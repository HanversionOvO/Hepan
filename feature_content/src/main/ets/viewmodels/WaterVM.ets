import { BaseVM, WaterApi, WaterModels } from 'base_common';
import { CustomTabItem, LongTakeAnimationProperties } from 'base_ui';

@ObservedV2
export class WaterVM extends BaseVM {
  @Trace longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @Trace water: WaterModels = new WaterModels();
  @Trace isShowWaterDetailSheet: boolean = false;
  @Trace tabItems: CustomTabItem[] = [
    { label: $r('app.string.WaterPage_get_water'), icon: $r('sys.symbol.light') },
    { label: $r('app.string.WaterPage_store'), icon: $r('sys.symbol.store') },
    { label: $r('app.string.WaterPage_backpack'), icon: $r('sys.symbol.card_package') },
    { label: $r('app.string.WaterPage_transfer'), icon: $r('sys.symbol.wallet') }
  ];

  async loadData() {
    this.water = await WaterApi.getWaterSummary();
  }
}