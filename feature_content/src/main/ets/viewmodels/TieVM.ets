import { BaseVM } from 'base_common';
import { CustomTabItem } from 'base_ui';

@ObservedV2
export class TieVM extends BaseVM {
  @Trace categoryTabItems: CustomTabItem[] = [
    { label: $r('app.string.ContentPage_tab_tie'), icon: $r('sys.symbol.book') },
    { label: $r('app.string.ContentPage_tab_collection'), icon: $r('sys.symbol.folder') },
    { label: $r('app.string.ContentPage_tab_water_drop'), icon: $r('sys.symbol.drop') }
  ];
}