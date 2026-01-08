import { BaseVM } from 'base_common';
import { CustomTabItem } from 'base_ui';

@ObservedV2
export class CollectionVM extends BaseVM {
  @Trace sortTabItems: CustomTabItem[] = [];
  @Trace currentSort: number = 0;
  @Trace isRefreshing: boolean = false;
}