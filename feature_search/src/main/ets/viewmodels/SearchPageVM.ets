import { AppUtil } from '@pura/harmony-utils';
import { BaseVM, CommonConstant, RouterUtil } from 'base_common';
import { CustomTabItem } from 'base_ui';

@ObservedV2
export class SearchPageVM extends BaseVM {
  @Trace tabItems: CustomTabItem[] = [
    { label: "搜帖子", icon: $r('sys.symbol.book') },
    { label: "搜用户", icon: $r('sys.symbol.person') }
  ]

  back() {
    AppUtil.getUIContext()
      .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveNormal },
        () => {
          RouterUtil.pop(undefined, false);
        })
  }
}