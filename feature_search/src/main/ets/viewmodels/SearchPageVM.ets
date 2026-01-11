import { AppUtil } from '@pura/harmony-utils';
import { BaseVM, CommonConstant, RouterUtil } from 'base_common';
import { CustomTabItem } from 'base_ui';

@ObservedV2
export class SearchPageVM extends BaseVM {
  @Trace tabItems: CustomTabItem[] = [
    { label: $r('app.string.SearchPage_query_tie'), icon: $r('sys.symbol.book') },
    { label: $r('app.string.SearchPage_query_user'), icon: $r('sys.symbol.person') }
  ]

  back() {
    AppUtil.getUIContext()
      .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveNormal },
        () => {
          RouterUtil.pop(undefined, false);
        })
  }
}