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
  @Trace uploadedImages: string[] = [];
  @Trace categories: PostCategories[] = [];

  get currentMainCategoryName(): ResourceStr {
    if (this.categories.length > 0 && this.currentCategory >= 0 && this.currentCategory < this.categories.length) {
      return this.categories[this.currentCategory].name;
    }
    return $r('app.string.PostPage_choose_category_first');
  }

  async startPostPage() {
    this.categories = await ForumApi.getPostCategories();

    this.categoryTabs = this.categories.map((category) => {
      return {
        label: category.name,
        icon: $r('sys.symbol.person')
      } as CustomTabItem;
    });

    if (this.categories.length > 0) {
      this.currentCategory = 0;
      const firstCategory = this.categories[0];

      if (firstCategory.children && firstCategory.children.length > 0) {
        this.selectedSubCategory = firstCategory.children[0].name;
      } else {
        this.selectedSubCategory = '';
      }
    }
  }
}