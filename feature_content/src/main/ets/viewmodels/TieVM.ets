import {
  BaseVM,
  BreakpointNameEnum,
  BreakpointType,
  CommonConstant,
  ForumApi,
  ForumCategory,
  ForumTieSummary,
  RouterMap,
  RouterUtil
} from 'base_common';
import { CustomTabItem, LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'base_ui';
import { SortItem, TieSortType } from '../components/SortButton'; // 确保引入 TieSortType
import { SubCategoryItem } from '../components/SubCategoryButton';
import { LogUtil } from '@pura/harmony-utils';
import { LongTakeTransitionOptions } from 'base_ui/src/main/ets/transitions/longtake/utils/Options';
import { curves } from '@kit.ArkUI';

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
  @Trace isScaling: boolean = false;
  @Trace pageScale: number = 1;
  private page: number = 1;
  // 用于缓存板块ID到名称的映射，供TieCard显示使用
  private forumNameMap: Map<number, string> = new Map();
  // 缓存原始的版块列表数据，用于切换二级版块时无需再次请求网络
  private rawCategoryList: ForumCategory[] = [];

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
      idlist: "newthread",
      name: $r('app.string.TieView_sort_newthread'),
      icon: $r('sys.symbol.edit_badge_star')
    },
    {
      id: 1,
      idlist: "newreply",
      name: $r('app.string.TieView_sort_newreply'),
      icon: $r('sys.symbol.message')
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
    try {
      const result: ForumCategory[] = await ForumApi.getForumCategory();
      this.rawCategoryList = result; // 缓存

      // 构建FID映射
      this.buildForumMap(result);

      const categories: CategoryTabItems[] = [];
      const icon: Resource = $r('sys.symbol.list_number');

      categories.push({
        fid: 0,
        label: $r('app.string.TieView_category_all'),
        icon
      });

      result.forEach((category: ForumCategory) => {
        categories.push({
          fid: category.fid,
          label: category.name,
          icon
        });
      });

      this.categoryTabItems = categories;
    } catch (e) {
      LogUtil.error(TAG, 'Load category failed: ' + JSON.stringify(e));
    }
  }

  private buildForumMap(list: ForumCategory[]) {
    if (!list || list.length === 0) {
      return;
    }
    list.forEach(item => {
      this.forumNameMap.set(item.fid, item.name);
      if (item.children && item.children.length > 0) {
        this.buildForumMap(item.children);
      }
    });
  }

  // 提供给 TieCard 使用
  getForumName(fid: number): string {
    return this.forumNameMap.get(fid) || '';
  }

  /**
   * 加载二级版块
   * 修改点：当一级版块为具体版块且有子版块时，不显示“全部”，而是直接显示子版块列表。
   * 结合 changeCategory 中的 currentSubCategory = 0 重置逻辑，会自动选中第一个子版块。
   */
  async loadSubCategory() {
    const currentFid: number = this.categoryTabItems[this.currentCategory]?.fid || 0;
    let categories: SubCategoryItem[] = [];

    // 只有当一级版块是“全部”时，才显示“全部”选项
    if (currentFid === 0) {
      categories.push({ fid: 0, name: $r('app.string.TieView_category_all') });
    } else {
      let hasChildren = false;
      if (this.rawCategoryList.length > 0) {
        // 在缓存的一级列表中查找当前选中的父版块
        const parentCategory = this.rawCategoryList.find(item => item.fid === currentFid);

        if (parentCategory && parentCategory.children && parentCategory.children.length > 0) {
          hasChildren = true;
          parentCategory.children.forEach((child: ForumCategory) => {
            categories.push({
              fid: child.fid,
              name: child.name
            });
          });
        }
      }

      // 如果具体版块没有子版块，则显示“全部”（代表父版块自己），避免空白
      if (!hasChildren) {
        categories.push({ fid: 0, name: $r('app.string.TieView_category_all') });
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
    // 切换一级版块时，重置二级版块选择为 0
    // 如果子版块列表中没有“全部”，0 就是第一个子版块
    this.currentSubCategory = 0;
    this.isSorting = false;
    this.loadSubCategory();
    this.updateSortItems();

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

  /**
   * 将字符串类型的排序转换为 API 需要的数字类型
   */
  private getSortByValue(type: TieSortType): number {
    switch (type) {
      case "newreply":
        return 1;
      case "newthread":
        return 2;
      case "allreplies":
        return 3;
      case "allvisits":
        return 4;
      case "hotlist":
        return 4;
      default:
        return 1;
    }
  }

  // 加载数据的方法
  async loadTies(refresh: boolean) {
    if (this.isLoadingTie) {
      return;
    }
    this.isLoadingTie = true;

    if (refresh) {
      this.page = 1;
      this.isRefreshTie = true;
    }

    try {
      const currentSortItem = this.sortItems[this.currentSort];
      const idlist: TieSortType = currentSortItem ? currentSortItem.idlist : "newreply";

      let data: ForumTieSummary[] = [];

      const parentFid = this.categoryTabItems[this.currentCategory]?.fid || 0;
      const subFid = this.subCategoryItems[this.currentSubCategory]?.fid || 0;

      // 确定最终使用的 fid
      // 如果 subFid > 0，说明选中了具体的子版块（因为已经去掉了具体的fid=0的“全部”选项，除非是 fallback）
      // 如果 subFid == 0，说明是一级“全部”或者无子版块的Fallback“全部”，此时用 parentFid
      const targetFid = (subFid > 0) ? subFid : parentFid;

      if (targetFid > 0) {
        const sortBy = this.getSortByValue(idlist);
        data = await ForumApi.getForumThreads(targetFid, sortBy, this.page);
      } else {
        data = await ForumApi.getForumTie(idlist, this.page);
      }

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

  enterDetailPage(tid: string, context: UIContext, tieSummary: ForumTieSummary) {
    let options: LongTakeTransitionOptions = {
      onEnterTransitionStart: () => {
        context.animateTo({ curve: curves.springMotion(0.35, 0.75) }, () => {
          this.pageScale = 0.8;
        })
      },
      onBackTransitionStart: () => {
        context.animateTo({ curve: curves.springMotion(0.35, 0.75) }, () => {
          this.pageScale = 1.0;
        })
      }
    };

    let longTakeTransitionParam: LongTakeTransitionParam | undefined =
      LoneTakeAnimationsTransition.generateLongTakeParam(context,
        tid, CommonConstant.RadiusLarge, options);

    const params: Record<string, Object> = {};

    if (longTakeTransitionParam) {
      let transitionParam: LongTakeTransitionParam = longTakeTransitionParam;
      params["transition"] = transitionParam;
    }

    params["tieSummary"] = tieSummary;

    RouterUtil.pushPathByName(RouterMap.TIE_CONTENT_PAGE, params);
  }
}