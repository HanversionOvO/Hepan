import { BaseVM } from 'base_common';
import { CustomTabItem } from 'base_ui';

@ObservedV2
export class CollectionVM extends BaseVM {
  @Trace sortTabItems: CustomTabItem[] = [
    { label: "推荐", icon: $r('sys.symbol.star') },
    { label: "按主题", icon: $r('sys.symbol.star') },
    { label: "按订阅数", icon: $r('sys.symbol.star') },
  ];
  @Trace currentSort: number = 0;
  @Trace isRefreshing: boolean = false;
}