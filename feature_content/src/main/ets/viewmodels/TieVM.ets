import {
  BaseVM,
  BreakpointNameEnum,
  BreakpointType,
  ForumApi,
  ForumCategory,
  ForumTieSummary,
  PostCategoryGroup
} from 'base_common';
import { CustomTabItem } from 'base_ui';
import { SortItem, TieSortType } from '../components/SortButton';
import { SubCategoryItem } from '../components/SubCategoryButton';
import { LogUtil } from '@pura/harmony-utils';

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
  @Trace sortItems: SortItem[] = [];
  @Trace ties: ForumTieSummary[] = [];
  @Trace isSubCategoryExpanded: boolean = false;
  @Trace isSorting: boolean = false;
  @Trace isRefreshTie: boolean = false;
  @Trace columns: number = 2;
  @Trace minColumns: number = 1;
  @Trace maxColumns: number = 3;
  // 分页与加载状态
  @Trace isLoadingTie: boolean = false;
  private page: number = 1;
  // 用于缓存板块ID到名称的映射，供TieCard显示使用
  private forumNameMap: Map<number, string> = new Map();

  @Monitor("breakPoint.currentBreakPoint")
  onBreakpointChange() {
    this.updateGridConfig(this.breakPoint.currentBreakPoint);
  }

  @Monitor("currentSort")
  onSortChange() {
    // 排序切换时刷新数据
    this.loadTies(true);
  }

  private readonly defaultSortItems: SortItem[] = [
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
  ];
  private readonly otherSortItems: SortItem[] = [
    {
      id: 1,
      idlist: "newreply",
      name: $r('app.string.TieView_sort_newreply'),
      icon: $r('sys.symbol.message')
    },
    {
      id: 2,
      idlist: "newthread",
      name: $r('app.string.TieView_sort_newthread'),
      icon: $r('sys.symbol.edit_badge_star')
    },
    {
      id: 3,
      idlist: "allreplies",
      name: $r('app.string.TieView_sort_allreplies'),
      icon: $r('sys.symbol.message')
    },
    {
      id: 4,
      idlist: "allvisits",
      name: $r('app.string.TieView_sort_allvisits'),
      icon: $r('sys.symbol.flame')
    }
  ];
  private defaultColumnsConfig = new BreakpointType({
    sm: 2,
    md: 3,
    lg: 4,
    xl: 5
  });
  private minColumnsConfig = new BreakpointType({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 4
  });
  private maxColumnsConfig = new BreakpointType({
    sm: 2,
    md: 4,
    lg: 5,
    xl: 6
  });

  updateGridConfig(bp: BreakpointNameEnum) {
    this.columns = this.defaultColumnsConfig.getValue(bp);
    this.minColumns = this.minColumnsConfig.getValue(bp);
    this.maxColumns = this.maxColumnsConfig.getValue(bp);
  }

  async loadCategory() {
    const result = await ForumApi.getPostCategories();
    // 构建FID映射
    this.buildForumMap(result);

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

  private buildForumMap(groups: PostCategoryGroup[]) {
    groups.forEach(group => {
      this.forumNameMap.set(group.fid, group.name);
      if (group.children) {
        group.children.forEach(child => {
          this.forumNameMap.set(child.fid, child.name);
        })
      }
    });
  }

  // 提供给 TieCard 使用
  getForumName(fid: number): string {
    return this.forumNameMap.get(fid) || '';
  }

  async loadSubCategory() {
    const fid: number = this.categoryTabItems[this.currentCategory].fid;
    let categories: SubCategoryItem[] = [];
    if (fid === 0 || fid === -1) {
      categories = [
        { fid: 0, name: $r('app.string.TieView_category_no_sub') },
      ];
    } else {
      const result = await ForumApi.getForumDetails(fid);
      if (result.children) {
        result.children.forEach((subCategory: ForumCategory) => {
          categories.push({
            fid: subCategory.fid,
            name: subCategory.name
          })
          // 补充详情中的子版块到映射表
          this.forumNameMap.set(subCategory.fid, subCategory.name);
        })
      } else {
        categories = [
          { fid: 0, name: $r('app.string.TieView_category_no_sub') },
        ];
      }
    }

    this.subCategoryItems = categories;
  }

  updateSortItems() {
    if (this.categoryTabItems.length === 0) {
      return;
    }
    const fid: number = this.categoryTabItems[this.currentCategory].fid;

    if (fid === 0) {
      this.sortItems = this.defaultSortItems;
    } else {
      this.sortItems = this.otherSortItems;
    }

    // 重置排序索引（这会触发 Monitor 从而调用 loadTies）
    this.currentSort = 0;
  }

  async loadData() {
    await this.loadCategory();
    this.updateSortItems();
    await this.loadSubCategory();
    this.updateGridConfig(this.breakPoint.currentBreakPoint);
    // 初始加载
    await this.loadTies(true);
  }

  changeCategory(index: number) {
    if (this.currentCategory === index) {
      return;
    }
    this.currentCategory = index;
    this.currentSubCategory = 0;
    this.isSorting = false;
    this.loadSubCategory();
    this.updateSortItems();
    // 如果 updateSortItems 将 currentSort 重置为 0 且原本就是 0，Monitor 不会触发，需要手动加载
    if (this.currentSort === 0) {
      this.loadTies(true);
    }
  }

  changeSubCategory(index: number) {
    this.currentSubCategory = index;
    this.currentSort = 0;
    this.isSorting = false;
    this.loadTies(true);
  }

  // 加载数据的方法
  async loadTies(refresh: boolean) {
    if (this.isLoading) {
      return;
    }
    this.isLoadingTie = true;

    if (refresh) {
      this.page = 1;
      this.isRefreshTie = true;
    }

    try {
      const currentSortItem = this.sortItems[this.currentSort];
      // FIX: 显式指定类型为 SortItem['idlist']，避免使用 any，同时处理 undefined 的情况
      const idlist: TieSortType = currentSortItem ? currentSortItem.idlist : "newreply";

      const data = await ForumApi.getForumTie(idlist, this.page);

      if (refresh) {
        this.ties = data;
      } else {
        this.ties.push(...data);
      }

      if (data.length > 0) {
        this.page++;
      }
    } catch (error) {
      LogUtil.error(TAG, "Failed to load ties: " + JSON.stringify(error));
    } finally {
      this.isLoadingTie = false;
      this.isRefreshTie = false;
    }
  }

  loadNextPage() {
    this.loadTies(false);
  }
}