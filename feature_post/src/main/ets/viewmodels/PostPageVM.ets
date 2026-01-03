import { MarkdownController } from '@luvi/lv-markdown-in';
import { AppUtil, ResUtil } from '@pura/harmony-utils';
import {
  AtUser,
  BaseVM,
  CommonConstant,
  ForumApi,
  InputOverlayStore,
  InputOverlayVisibilityEvent,
  PostCategories
} from 'base_common';
import { CustomTabItem, NavTitleButtonModel } from 'base_ui';
import { RichTextButton } from '../components/RichTextToolBar';
import { inputMethod } from '@kit.IMEKit';

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
  @Trace isInputtingWithKeyboard: boolean = false;
  @Trace isPreviewMode: boolean = false;
  @Trace isShowFace: boolean = false;
  @Trace isShowAt: boolean = false;
  @Trace markdownController: MarkdownController = new MarkdownController();
  @Trace contentSelectionStart: number = 0;
  @Trace contentSelectionEnd: number = 0;
  @Trace markdownContent: string = '';
  @Trace postTitle: string = '';
  @Trace categoryTabs: CustomTabItem[] = [];
  @Trace uploadedImages: string[] = [];
  @Trace categories: PostCategories[] = [];
  @Trace richTextButtons: RichTextButton[] = [
    {
      icon: $r('sys.symbol.capture_smiles'), onClick: () => {
      this.isShowFace = !this.isShowFace;
      this.isShowAt = false;
      this.isInputtingWithKeyboard = false;
      if (this.isShowFace) {
        try {
          inputMethod.getController().stopInputSession();
        } catch (error) {
          console.error(TAG, 'Stop input session failed:', error);
        }

        AppUtil.getUIContext()
          .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring },
            () => {
              this.isInputting = true;
            })
      } else {
        AppUtil.getUIContext()
          .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring },
            () => {
              this.isInputting = false;
            })
      }
      this.emitInputOverlayVisibility();
    }
    },
    {
      icon: $r('sys.symbol.at'), onClick: () => {
      this.isShowAt = !this.isShowAt;
      this.isShowFace = false;
      this.isInputtingWithKeyboard = false;

      if (this.isShowAt) {
        try {
          inputMethod.getController().stopInputSession();
        } catch (error) {
          console.error(TAG, 'Stop input session failed:', error);
        }
        AppUtil.getUIContext()
          .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring },
            () => {
              this.isInputting = true;
            })
      } else {
        AppUtil.getUIContext()
          .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring },
            () => {
              this.isInputting = false;
            })
      }
      this.emitInputOverlayVisibility();
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

  setKeyboardInputting(isVisible: boolean) {
    this.isInputtingWithKeyboard = isVisible;
    this.emitInputOverlayVisibility();
  }

  emitInputOverlayVisibility() {
    InputOverlayStore.emit(InputOverlayVisibilityEvent,
      this.isShowFace || this.isShowAt || this.isInputtingWithKeyboard);
  }

  updateContentSelection(start: number, end: number) {
    this.contentSelectionStart = Math.max(0, start);
    this.contentSelectionEnd = Math.max(0, end);
  }

  private insertTextAtCursor(text: string) {
    const start = Math.min(this.contentSelectionStart, this.contentSelectionEnd);
    const end = Math.max(this.contentSelectionStart, this.contentSelectionEnd);
    const before = this.markdownContent.slice(0, start);
    const after = this.markdownContent.slice(end);
    this.markdownContent = `${before}${text}${after}`;
    const newCursor = start + text.length;
    this.updateContentSelection(newCursor, newCursor);
  }

  insertFace(url: string) {
    const faceText = `![](${url})`;
    this.insertTextAtCursor(faceText);
  }

  insertAtUser(atUser: AtUser) {
    const atText = `[@${atUser.username}](at:${atUser.uid}) `;
    this.insertTextAtCursor(atText);
  }

  applyBold() {
    this.wrapSelection('**');
  }

  applyItalic() {
    this.wrapSelection('*');
  }

  applyUnderline() {
    this.wrapSelection('<u>', '</u>');
  }

  applyStrikethrough() {
    this.wrapSelection('~~');
  }

  applyOrderedList() {
    this.prefixLines((index: number) => `${index + 1}. `, ResUtil.getStringSync($r('app.string.PostPage_list_item')));
  }

  applyUnorderedList() {
    this.prefixLines(() => '- ', ResUtil.getStringSync($r('app.string.PostPage_list_item')));
  }

  insertDivider() {
    const start = Math.min(this.contentSelectionStart, this.contentSelectionEnd);
    const end = Math.max(this.contentSelectionStart, this.contentSelectionEnd);
    const before = this.markdownContent.slice(0, start);
    const after = this.markdownContent.slice(end);
    const leading = before.endsWith('\n') || before.length === 0 ? '' : '\n';
    const trailing = after.startsWith('\n') || after.length === 0 ? '' : '\n';
    const divider = `${leading}---${trailing}`;
    this.markdownContent = `${before}${divider}${after}`;
    const newCursor = before.length + divider.length;
    this.updateContentSelection(newCursor, newCursor);
  }

  applyTaskList() {
    this.prefixLines(() => '- [ ] ', ResUtil.getStringSync($r('app.string.PostPage_todo')));
  }

  applyQuote() {
    this.prefixLines(() => '> ', ResUtil.getStringSync($r('app.string.PostPage_quote')));
  }

  private wrapSelection(prefix: string, suffix: string = prefix, placeholder: string = '') {
    const start = Math.min(this.contentSelectionStart, this.contentSelectionEnd);
    const end = Math.max(this.contentSelectionStart, this.contentSelectionEnd);
    const before = this.markdownContent.slice(0, start);
    const selected = this.markdownContent.slice(start, end);
    const content = selected.length > 0 ? selected : placeholder;
    const after = this.markdownContent.slice(end);
    this.markdownContent = `${before}${prefix}${content}${suffix}${after}`;
    const selectionStart = before.length + prefix.length;
    const selectionEnd = selectionStart + content.length;
    this.updateContentSelection(selectionStart, selectionEnd);
  }

  private prefixLines(prefixBuilder: (index: number) => string, placeholder: string) {
    const start = Math.min(this.contentSelectionStart, this.contentSelectionEnd);
    const end = Math.max(this.contentSelectionStart, this.contentSelectionEnd);
    const before = this.markdownContent.slice(0, start);
    const selected = this.markdownContent.slice(start, end);
    const content = selected.length > 0 ? selected : placeholder;
    const lines = content.split('\n');
    const formattedLines = lines.map((line: string, index: number) => {
      const prefix = prefixBuilder(index);
      const lineContent = line.length > 0 ? line : placeholder;
      return `${prefix}${lineContent}`;
    }).join('\n');
    const after = this.markdownContent.slice(end);
    this.markdownContent = `${before}${formattedLines}${after}`;
    const selectionStart = before.length;
    const selectionEnd = selectionStart + formattedLines.length;
    this.updateContentSelection(selectionStart, selectionEnd);
  }
}