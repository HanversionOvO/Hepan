import { BaseVM, ForumApi, ForumCategory, PostCategoryGroup } from 'base_common';
import { CustomTabItem } from 'base_ui';
import { SortItem } from '../components/SortButton';
import { SubCategoryItem } from '../components/SubCategoryButton';

const TAG = '[TieVM]: ';

export interface CategoryTabItems extends CustomTabItem {
  fid: number;
}

@ObservedV2
export class TieVM extends BaseVM {
  @Trace categoryTabItems: CategoryTabItems[] = [];
  @Trace currentCategory: number = 0;
  @Trace currentSubCategory: number = 0;
  @Trace currentSort: number = 0;
  @Trace subCategoryItems: SubCategoryItem[] = [
    { fid: 0, name: $r('app.string.TieView_category_all') },
  ];
  @Trace sortItems: SortItem[] = [
    { id: 0, name: "test1", icon: $r('sys.symbol.person') },
    { id: 1, name: "test2", icon: $r('sys.symbol.person') },
    { id: 2, name: "test3", icon: $r('sys.symbol.person') },
  ]
  @Trace isSubCategoryExpanded: boolean = false;
  @Trace isSorting: boolean = false;

  async loadCategory() {
    const result = await ForumApi.getPostCategories();
    const categories: CategoryTabItems[] = [];
    const icon: Resource = $r('sys.symbol.list_number');

    categories.push({
      fid: 0,
      label: $r('app.string.TieView_category_all'),
      icon
    })

    result.forEach((category: PostCategoryGroup) => {
      categories.push({
        fid: category.children[0].fid,
        label: category.children[0].name,
        icon
      })
    })

    categories.push({
      fid: -1,
      label: $r('app.string.TieView_category_more'),
      icon
    })

    this.categoryTabItems = categories;
  }

  async loadSubCategory() {
    if (this.currentCategory === 0 || this.currentCategory === -1) {
      this.subCategoryItems = [
        { fid: 0, name: $r('app.string.TieView_category_no_sub') },
      ];
      return;
    }

    this.subCategoryItems = [];

    const result = await ForumApi.getForumDetails(this.categoryTabItems[this.currentCategory].fid);
    if (result.children) {
      result.children.forEach((subCategory: ForumCategory) => {
        this.subCategoryItems.push({
          fid: subCategory.fid,
          name: subCategory.name
        })
      })
    } else {
      this.subCategoryItems = [
        { fid: 0, name: $r('app.string.TieView_category_no_sub') },
      ];
    }
  }

  async loadData() {
    await this.loadCategory();
    await this.loadSubCategory();
  }

  changeCategory(index: number) {
    this.currentCategory = index;
    this.loadSubCategory();
  }
}