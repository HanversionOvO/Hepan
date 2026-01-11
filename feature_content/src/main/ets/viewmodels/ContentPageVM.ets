import { AppUtil } from '@pura/harmony-utils';
import { BaseVM, CommonConstant, RouterMap, RouterUtil } from 'base_common';
import { CustomTabItem, NavTitleButtonModel } from 'base_ui';

@ObservedV2
export class ContentPageVM extends BaseVM {
  @Trace titleButtons: NavTitleButtonModel[] = [
    {
      icon: $r('sys.symbol.magnifyingglass'), onClick: () => {
      AppUtil.getUIContext()
        .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveNormal },
          () => {
            RouterUtil.pushPathByName(RouterMap.SEARCH_PAGE, null, undefined, false);
          })
    }
    }
  ]
  @Trace contentPageTabItems: CustomTabItem[] = [
    { label: $r('app.string.ContentPage_tab_tie'), icon: $r('sys.symbol.book') },
    { label: $r('app.string.ContentPage_tab_collection'), icon: $r('sys.symbol.folder') },
    { label: $r('app.string.ContentPage_tab_app'), icon: $r('sys.symbol.more') }
  ];
  @Trace currentIndex: number = 0;

  changeTab(index: number) {
    this.currentIndex = index;
  }
}