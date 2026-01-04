import { BaseVM } from 'base_common';
import { CustomTabItem } from 'base_ui';
import { SortItem } from '../components/SortButton';
import { SubCategoryItem } from '../components/SubCategoryButton';

@ObservedV2
export class TieVM extends BaseVM {
  @Trace categoryTabItems: CustomTabItem[] = [
    { label: $r('app.string.ContentPage_tab_tie'), icon: $r('sys.symbol.book') },
    { label: $r('app.string.ContentPage_tab_collection'), icon: $r('sys.symbol.folder') },
    { label: $r('app.string.ContentPage_tab_water_drop'), icon: $r('sys.symbol.drop') }
  ];
  @Trace currentCategory: number = 0;
  @Trace currentSubCategory: number = 0;
  @Trace currentSort: number = 0;
  @Trace subCategoryItems: SubCategoryItem[] = [
    { id: 0, name: "test1" },
    { id: 1, name: "test2" },
    { id: 2, name: "test3" },
  ];
  @Trace sortItems: SortItem[] = [
    { id: 0, name: "test1", icon: $r('sys.symbol.person') },
    { id: 1, name: "test2", icon: $r('sys.symbol.person') },
    { id: 2, name: "test3", icon: $r('sys.symbol.person') },
  ]
  @Trace isSubCategoryExpanded: boolean = false;
  @Trace isSorting: boolean = false;
}