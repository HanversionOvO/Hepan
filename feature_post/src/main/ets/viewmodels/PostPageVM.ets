import { BaseVM } from 'base_common';
import { CustomTabItem, NavTitleButtonModel } from 'base_ui';

@ObservedV2
export class PostPageVM extends BaseVM {
  @Trace titleButtons: NavTitleButtonModel[] = [];
  @Trace selectedCategory: number = 0;
  @Trace currentCategory: number = 0;
  @Trace selectedSubCategory: string = '';
  @Trace isCategoryExpanded: boolean = false;
  @Trace postTitle: string = '';
  @Trace categoryTabs: CustomTabItem[] = [
    { label: "test", icon: $r('sys.symbol.person') },
    { label: "test", icon: $r('sys.symbol.person') },
  ];
  @Trace uploadedImages: string[] = [
    'https://t.alcy.cc/pc',
    'https://t.alcy.cc/pc',
    'https://t.alcy.cc/pc',
    'https://t.alcy.cc/pc',
    'https://t.alcy.cc/pc',
  ];
  @Trace categories: Record<string, Object>[] = [];

  get currentMainKey(): string {
    const keys = Object.keys(this.categories);
    if (this.currentCategory >= 0 && this.currentCategory < keys.length) {
      return keys[this.currentCategory];
    }
    return keys[0];
  }
}