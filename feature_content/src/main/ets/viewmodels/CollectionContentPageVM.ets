import { BaseVM } from 'base_common';
import { LongTakeAnimationProperties } from 'base_ui';

@ObservedV2
export class CollectionContentPageVM extends BaseVM {
  @Trace isCollectionRefreshing: boolean = false;
  @Trace longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
}