import { BaseVM } from 'base_common';
import { LongTakeAnimationProperties } from 'base_ui';

@ObservedV2
export class WaterVM extends BaseVM {
  @Trace longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
}