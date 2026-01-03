import { MarkdownController } from '@luvi/lv-markdown-in';
import { BaseVM, ForumApi, PostCategories } from 'base_common';
import { CustomTabItem, NavTitleButtonModel } from 'base_ui';
import { RichTextButton } from '../components/RichTextToolBar';

const TAG = '[PostPageVM]: ';

@ObservedV2
export class PostPageVM extends BaseVM {
  @Trace titleButtons: NavTitleButtonModel[] = [
    {
      icon: $r('sys.symbol.save'), onClick: () => {
    }
    },
    {
      icon: $r('sys.symbol.paperplane'), onClick: () => {
    }
    }
  ];
  @Trace selectedCategory: number = 0;
  @Trace currentCategory: number = 0;
  @Trace selectedSubCategory: string = '';
  @Trace isCategoryExpanded: boolean = false;
  @Trace isInputting: boolean = false;
  @Trace isPreviewMode: boolean = false;
  @Trace markdownController: MarkdownController = new MarkdownController();
  @Trace markdownContent: string = '';
  @Trace postTitle: string = '';
  @Trace categoryTabs: CustomTabItem[] = [];
  @Trace uploadedImages: string[] = [];
  @Trace categories: PostCategories[] = [];
  @Trace richTextButtons: RichTextButton[] = [
    {
      icon: $r('sys.symbol.capture_smiles'), onClick: () => {
    }
    },
    {
      icon: $r('sys.symbol.at'), onClick: () => {
    }
    },
    {
      icon: $r('sys.symbol.picture'), onClick: () => {
    }
    },
    {
      icon: $r('sys.symbol.link'), onClick: () => {
    }
    }
  ];

  get currentMainCategoryName(): ResourceStr {
    if (this.categories.length > 0 && this.currentCategory >= 0 && this.currentCategory < this.categories.length) {
      return this.categories[this.currentCategory].name;
    }
    return $r('app.string.PostPage_choose_category_first');
  }

  selectMainCategory(index: number) {
    this.currentCategory = index;
    if (this.categories.length > index && index >= 0) {
      const category = this.categories[index];
      if (category.children && category.children.length > 0) {
        this.selectedSubCategory = category.children[0].name;
      } else {
        this.selectedSubCategory = '';
      }
    }
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
      this.selectMainCategory(0);
    }
  }
}