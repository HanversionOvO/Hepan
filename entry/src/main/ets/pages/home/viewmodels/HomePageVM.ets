import { BaseVM, InputOverlayStore, InputOverlayVisibilityEvent, RouterUtil, StorageManager } from 'base_common';
import { HomeNavBarItem } from '../components/HomeNavBar';

const TAG = '[HomePageVM]: ';

@ObservedV2
export class HomePageVM extends BaseVM {
  @Trace homeNavBarItem: HomeNavBarItem[] = [
    { name: 'home', icon: $r('sys.symbol.house'), title: '首页' },
    { name: 'video', icon: $r('sys.symbol.doc_plaintext_and_pencil'), title: '发帖' },
    { name: 'message', icon: $r('sys.symbol.message_on_message'), title: '消息' },
    { name: 'mine', icon: $r('sys.symbol.person'), title: '我的' }
  ];
  @Trace currentIndex: number = StorageManager.tabIndexModel.homeTabIndex;
  @Trace controller: TabsController = new TabsController();
  @Trace isKeyBoardOpen: boolean = false;
  @Trace isInputOverlayOpen: boolean = false;
  private inputOverlayListener: ((visible: boolean) => void) | null = null;

  @Computed
  get isNavBarVisible(): boolean {
    if (this.isTabletView) {
      return true;
    }

    if (this.currentIndex === 0 || this.currentIndex === 3) {
      return true;
    }

    if (this.currentIndex === 1 && this.isInputOverlayOpen) {
      return false;
    }

    if (RouterUtil.routerModel.messageStackSize > 0) {
      return false;
    }

    return true;
  }

  startHome() {
    if (!this.inputOverlayListener) {
      this.inputOverlayListener = (visible: boolean) => {
        this.isInputOverlayOpen = visible;
      };
      InputOverlayStore.on(InputOverlayVisibilityEvent, this.inputOverlayListener);
    }
    setTimeout(() => {
      this.window.showNavigation = false
    }, 50)
  }
  
  aboutToDisappear() {
    if (this.inputOverlayListener) {
      InputOverlayStore.off(InputOverlayVisibilityEvent, this.inputOverlayListener);
      this.inputOverlayListener = null;
    }
  }

  changeNavBar(index: number) {
    this.currentIndex = index;
  }
}