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
    {
      id: 0,
      idlist: "newreply",
      name: $r('app.string.TieView_sort_newreply'),
      icon: $r('sys.symbol.message')
    },
    {
      id: 1,
      idlist: "newthread",
      name: $r('app.string.TieView_sort_newthread'),
      icon: $r('sys.symbol.edit_badge_star')
    },
    {
      id: 2,
      idlist: "digest",
      name: $r('app.string.TieView_sort_digest'),
      icon: $r('sys.symbol.star')
    },
    {
      id: 3,
      idlist: "life",
      name: $r('app.string.TieView_sort_life'),
      icon: $r('sys.symbol.life_payment')
    },
    {
      id: 4,
      idlist: "hotlist",
      name: $r('app.string.TieView_sort_hotlist'),
      icon: $r('sys.symbol.flame')
    },
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
    const fid: number = this.categoryTabItems[this.currentCategory].fid;
    if (fid === 0 || fid === -1) {
      this.subCategoryItems = [
        { fid: 0, name: $r('app.string.TieView_category_no_sub') },
      ];
      return;
    }

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