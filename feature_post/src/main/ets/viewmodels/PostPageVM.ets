import { MarkdownController } from '@luvi/lv-markdown-in';
import { AppUtil, LogUtil, ResUtil } from '@pura/harmony-utils';
import {
  AttachmentApi,
  AtUser,
  BaseVM,
  CommonConstant,
  ForumApi,
  InputOverlayStore,
  InputOverlayVisibilityEvent,
  NewThreadRequest,
  PostCategoryGroup,
  PostCategoryItem,
  ThreadType,
  ToastUtil,
  UiState,
  UploadedFile
} from 'base_common';
import { CustomTabItem, NavTitleButtonModel } from 'base_ui';
import { RichTextButton } from '../components/RichTextToolBar';
import { inputMethod } from '@kit.IMEKit';
import { PickerUtil } from '@pura/picker_utils';
import { picker } from '@kit.CoreFileKit';

const TAG = '[PostPageVM]: ';
const BASE_URL = 'https://bbs.uestc.edu.cn';

@ObservedV2
export class PostImageModel {
  @Trace localUri: string = '';
  @Trace remoteUrl: string = '';
  @Trace isLoading: boolean = false;
  attachment: UploadedFile | null = null;

  constructor(localUri: string) {
    this.localUri = localUri;
    this.isLoading = true;
  }
}

@ObservedV2
export class PostPageVM extends BaseVM {
  @Trace titleButtons: NavTitleButtonModel[] = [
    {
      icon: $r('sys.symbol.save'), onClick: () => {
      this.isShowDraft = true;
    }
    },
    {
      icon: $r('sys.symbol.paperplane'), onClick: () => {
      this.publishThread();
    }
    }
  ];
  // === 分类选择相关状态 ===
  @Trace isCategoryExpanded: boolean = false; // 是否展开板块选择器
  @Trace leftPanelIndex: number = 0; // 左侧大区列表的选中索引

  @Trace selectedForumId: number = 0; // 已选板块ID
  @Trace selectedForumName: string = ''; // 已选板块名称
  @Trace selectedTypeId: number = 0; // 已选分类ID
  @Trace selectedTypeName: string = ''; // 已选分类名称

  @Trace categories: PostCategoryGroup[] = []; // 所有板块数据
  @Trace threadTypes: ThreadType[] = []; // 当前板块的分类数据

  // 2. 使用 UiState 管理状态
  @Trace categoriesStatus: UiState = UiState.LOADING;
  @Trace typesStatus: UiState = UiState.EMPTY;
  @Trace isInputting: boolean = false;
  @Trace isInputtingWithKeyboard: boolean = false;
  @Trace isPreviewMode: boolean = false;
  @Trace isShowFace: boolean = false;
  @Trace isShowAt: boolean = false;
  @Trace isInsertImageMode: boolean = false;
  @Trace isShowDraft: boolean = false;
  @Trace markdownController: MarkdownController = new MarkdownController();
  @Trace contentSelectionStart: number = 0;
  @Trace contentSelectionEnd: number = 0;
  @Trace markdownContent: string = '';
  @Trace postTitle: string = '';
  @Trace categoryTabs: CustomTabItem[] = [];
  @Trace uploadedImages: PostImageModel[] = [];
  @Trace richTextButtons: RichTextButton[] = [
    {
      icon: $r('sys.symbol.capture_smiles'), onClick: () => {
      this.isShowFace = !this.isShowFace;
      this.isShowAt = false;
      this.isInsertImageMode = false;
      this.isInputtingWithKeyboard = false;
      if (this.isShowFace) {
        try {
          inputMethod.getController().stopInputSession();
        } catch (error) {
          LogUtil.error(TAG, 'Stop input session failed:', error);
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
      this.isInsertImageMode = false;
      this.isInputtingWithKeyboard = false;

      if (this.isShowAt) {
        try {
          inputMethod.getController().stopInputSession();
        } catch (error) {
          LogUtil.error(TAG, 'Stop input session failed:', error);
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
      this.isInsertImageMode = !this.isInsertImageMode;
      this.isShowFace = false;
      this.isShowAt = false;

      if (this.isInsertImageMode) {
        try {
          inputMethod.getController().stopInputSession();
        } catch (error) {
          LogUtil.error(TAG, 'Stop input session failed:', error);
        }
        AppUtil.getUIContext().animateTo({
          duration: CommonConstant.AnimationDurationNormal,
          curve: CommonConstant.AnimationCurveSpring
        }, () => {
          this.isInputting = false;
        });
      }
    }
    },
    {
      icon: $r('sys.symbol.link'), onClick: () => {
      this.isInsertImageMode = false;
    }
    }
  ];

  // 切换左侧大区
  selectLeftPanel(index: number) {
    AppUtil.getUIContext()
      .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring },
        () => {
          this.leftPanelIndex = index;
        });
  }

  // 切换展开/收起状态
  toggleCategoryExpand() {
    AppUtil.getUIContext()
      .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring },
        () => {
          this.isCategoryExpanded = !this.isCategoryExpanded;
        });
  }

  // 选中具体板块
  async onForumSelected(item: PostCategoryItem, targetTypeId?: number) {
    if (this.selectedForumId === item.fid) {
      this.toggleCategoryExpand();
      return;
    }

    this.selectedForumId = item.fid;
    this.selectedForumName = item.name;
    this.selectedTypeId = 0;
    this.selectedTypeName = '';
    this.threadTypes = [];

    this.typesStatus = UiState.LOADING;
    AppUtil.getUIContext()
      .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring },
        () => {
          this.isCategoryExpanded = false;
        });

    try {
      const details = await ForumApi.getForumDetails(item.fid);
      if (details.thread_types && details.thread_types.length > 0) {
        this.threadTypes = details.thread_types;
        this.typesStatus = UiState.SUCCESS;

        if (targetTypeId) {
          const targetType = this.threadTypes.find(t => t.type_id === targetTypeId);
          if (targetType) {
            this.onTypeSelected(targetType);
          } else {
            this.onTypeSelected(this.threadTypes[0]);
          }
        } else {
          this.onTypeSelected(this.threadTypes[0]);
        }
      } else {
        this.typesStatus = UiState.EMPTY;
      }
    } catch (e) {
      LogUtil.error(TAG, 'Fetch forum details failed:', e);
      this.typesStatus = UiState.ERROR;
    }
  }

  onTypeSelected(type: ThreadType) {
    this.selectedTypeId = type.type_id;
    this.selectedTypeName = type.name;
  }

  async startPostPage() {
    this.categoriesStatus = UiState.LOADING;
    try {
      this.categories = await ForumApi.getPostCategories();
      if (this.categories.length > 0) {
        this.categoriesStatus = UiState.SUCCESS;

        let isDefaultFound = false;

        for (let i = 0; i < this.categories.length; i++) {
          const group = this.categories[i];
          if (group.children && group.children.length > 0) {
            const targetItem = group.children.find(child => child.fid === 25);

            if (targetItem) {
              this.leftPanelIndex = i;
              await this.onForumSelected(targetItem, 315);
              isDefaultFound = true;
              break;
            }
          }
        }

        if (!isDefaultFound) {
          for (let i = 0; i < this.categories.length; i++) {
            const group = this.categories[i];
            if (group.children && group.children.length > 0) {
              this.leftPanelIndex = i;
              await this.onForumSelected(group.children[0]);
              break;
            }
          }
        }

      } else {
        this.categoriesStatus = UiState.EMPTY;
      }
    } catch (e) {
      LogUtil.error(TAG, 'Start post page failed:', e);
      this.categoriesStatus = UiState.ERROR;
    }
  }

  async selectImage() {
    const maxCount = 9 - this.uploadedImages.length;
    if (maxCount <= 0) {
      ToastUtil.showError($r('app.string.PostPage_select_photo_error'))
      return;
    }

    try {
      const uris = await PickerUtil.selectPhoto({
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: maxCount
      });

      if (uris && uris.length > 0) {
        uris.forEach((uri: string) => {
          const imgModel = new PostImageModel(uri);
          this.uploadedImages.push(imgModel);
          this.uploadImage(imgModel);
        });
      }
    } catch (e) {
      LogUtil.error(TAG, 'Select photo failed:', e);
    }
  }

  async uploadImage(img: PostImageModel) {
    try {
      const uploadedFile = await AttachmentApi.uploadImage(img.localUri);
      img.attachment = uploadedFile;
      // 优先使用 raw_url 或 thumbnail_url 进行显示
      let displayUrl = uploadedFile.raw_url || uploadedFile.thumbnail_url || uploadedFile.path;
      if (displayUrl && !displayUrl.startsWith('http')) {
        displayUrl = BASE_URL + displayUrl;
      }
      img.remoteUrl = displayUrl || '';
      img.isLoading = false;
    } catch (e) {
      LogUtil.error(TAG, 'Upload failed:', e);
      ToastUtil.showError($r('app.string.PostPage_photo_upload_failed'));
      const index = this.uploadedImages.indexOf(img);
      if (index !== -1) {
        this.uploadedImages.splice(index, 1);
      }
    }
  }

  deleteImage(index: number) {
    if (index >= 0 && index < this.uploadedImages.length) {
      AppUtil.getUIContext()
        .animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveNormal },
          () => {
            this.uploadedImages.splice(index, 1);
          })
    }
  }

  insertImageToContent(img: PostImageModel) {
    if (img.isLoading) {
      ToastUtil.showInfo($r('app.string.PostPage_photo_uploading'));
      return;
    }
    if (!img.remoteUrl) {
      ToastUtil.showError($r('app.string.PostPage_photo_upload_failed_insert'));
      return;
    }
    this.insertFace(img.remoteUrl);
    this.isInsertImageMode = false;
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

  async publishThread() {
    // 1. 校验输入
    if (this.selectedForumId === 0) {
      ToastUtil.showError($r('app.string.PostPage_choose_forum_first'));
      return;
    }
    if (this.selectedTypeId === 0 && this.threadTypes.length > 0) {
      ToastUtil.showError($r('app.string.PostPage_choose_category_first'));
      return;
    }
    if (!this.postTitle || this.postTitle.trim().length === 0) {
      ToastUtil.showError($r('app.string.PostPage_input_title'));
      return;
    }
    if (!this.markdownContent || this.markdownContent.trim().length === 0) {
      ToastUtil.showError($r('app.string.PostPage_input_content'));
      return;
    }

    // 检查图片是否还在上传中
    const isUploading = this.uploadedImages.some(img => img.isLoading);
    if (isUploading) {
      ToastUtil.showInfo($r('app.string.PostPage_photo_uploading'));
      return;
    }

    // 2. 显示 Loading
    ToastUtil.showLoading($r('app.string.PostPage_publishing'));

    try {
      // 3. 构建参数
      const attachments: UploadedFile[] = [];
      let finalMessage = this.markdownContent;

      this.uploadedImages.forEach(img => {
        if (img.attachment) {
          attachments.push(img.attachment);
          // 替换 Markdown 中的 URL 为 API 要求的格式 (i:attachment_id)
          // 注意：如果用户没有在文中插入图片，通常需要 append 到文末，这里为了简化，如果用户使用了 ![]() 语法，
          // 我们可以尝试替换，或者直接依靠 API 的 attachments 列表。
          // 更加稳健的做法是：只要传了 attachments 列表，Discuz 通常会自动处理。
          // 如果为了严格匹配文档 "message": "thread content\n\n[test.txt](a:2687361)\n\n![test.jpeg](i:2687364)\n"
          // 可以进行以下替换：
          if (img.remoteUrl) {
            // 简单的字符串替换，将 URL 替换为附件 ID 引用
            // 匹配 ![](URL) 或 [](URL)
            // 注意转义特殊字符
            const escapedUrl = img.remoteUrl.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            const regex = new RegExp(`\\!\\[.*?\\]\\(${escapedUrl}\\)`, 'g');
            // 如果文中引用了该图片，替换为 API 格式。
            // 实际上，如果保持 URL，服务端可能不会识别为附件引用，而是外部图片。
            // 建议替换。
            if (finalMessage.match(regex)) {
              finalMessage =
                finalMessage.replace(regex, `![${img.attachment.filename}](i:${img.attachment.attachment_id})`);
            } else {
              // 如果文中没有引用，则追加到文末
              finalMessage += `\n\n![${img.attachment.filename}](i:${img.attachment.attachment_id})`;
            }
          }
        }
      });

      const request: NewThreadRequest = {
        forum_id: this.selectedForumId,
        type_id: this.selectedTypeId,
        subject: this.postTitle,
        message: finalMessage,
        format: 2,
        usesig: 1,
        attachments: attachments
      };

      // 4. 调用接口
      const response = await ForumApi.newThread(request);

      // 5. 成功处理
      ToastUtil.hideLoading();
      ToastUtil.showSuccess($r('app.string.PostPage_publish_success'));

      // 清除内容
      this.clearPage();

    } catch (e) {
      ToastUtil.hideLoading();
      LogUtil.error(TAG, 'Publish thread failed:', e);
      ToastUtil.showError(e.message || $r('app.string.PostPage_publish_failed'));
    }
  }

  private clearPage() {
    this.postTitle = '';
    this.markdownContent = '';
    this.contentSelectionStart = 0;
    this.contentSelectionEnd = 0;
    this.uploadedImages = [];
  }
}