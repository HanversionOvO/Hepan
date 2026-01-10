import { BaseVM } from 'base_common';
import { CustomTabItem, NavTitleButtonModel } from 'base_ui';

@ObservedV2
export class ContentPageVM extends BaseVM {
  @Trace titleButtons: NavTitleButtonModel[] = [
    {
      icon: $r('sys.symbol.magnifyingglass'), onClick: () => {
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