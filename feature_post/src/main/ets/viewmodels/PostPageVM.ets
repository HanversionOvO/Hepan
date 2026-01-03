import { BaseVM, ForumApi, PostCategories } from 'base_common';
import { CustomTabItem, NavTitleButtonModel } from 'base_ui';

const TAG = '[PostPageVM]: ';

@ObservedV2
export class PostPageVM extends BaseVM {
  @Trace titleButtons: NavTitleButtonModel[] = [];
  @Trace selectedCategory: number = 0;
  @Trace currentCategory: number = 0;
  @Trace selectedSubCategory: string = '';
  @Trace isCategoryExpanded: boolean = false;
  @Trace postTitle: string = '';
  @Trace categoryTabs: CustomTabItem[] = [];
  @Trace uploadedImages: string[] = [
    'https://t.alcy.cc/pc',
    'https://t.alcy.cc/pc',
    'https://t.alcy.cc/pc',
    'https://t.alcy.cc/pc',
    'https://t.alcy.cc/pc',
  ];
  @Trace categories: PostCategories[] = [];

  get currentMainKey(): string {
    const keys = Object.keys(this.categories);
    if (this.currentCategory >= 0 && this.currentCategory < keys.length) {
      return keys[this.currentCategory];
    }
    return keys[0];
  }

  async startPostPage() {
    this.categories = await ForumApi.getPostCategories();
    this.categoryTabs = this.categories.map((category) => {
      return {
        label: category.name,
        icon: $r('sys.symbol.person')
      } as CustomTabItem;
    });
  }
}