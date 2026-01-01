import { BaseVM } from 'base_common';
import { CustomTabItem } from 'base_ui';

@ObservedV2
export class FansPageVM extends BaseVM {
  @Trace isHideTitleBar: boolean = false;
  @Trace currentFansTabIndex: number = 0;
  @Trace fansPageTabItems: CustomTabItem[] = [
    { label: $r('app.string.FansPage_friends'), icon: $r('sys.symbol.person_badge_plus') },
    { label: $r('app.string.FansPage_visitor'), icon: $r('sys.symbol.person_2') },
  ];

  changeFansTab(index: number) {
    this.currentFansTabIndex = index;
  }
}