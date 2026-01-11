import {
  BaseVM,
  InputOverlayStore,
  InputOverlayVisibilityEvent,
  ListenerManager,
  RouterUtil,
  StorageManager
} from 'base_common';
import { HomeNavBarItem } from '../components/HomeNavBar';

@ObservedV2
export class HomePageVM extends BaseVM {
  @Trace homeNavBarItem: HomeNavBarItem[] = [
    { name: 'home', icon: $r('sys.symbol.house'), title: $r('app.string.HomePage_home') },
    { name: 'video', icon: $r('sys.symbol.doc_plaintext_and_pencil'), title: $r('app.string.HomePage_post') },
    { name: 'message', icon: $r('sys.symbol.message_on_message'), title: $r('app.string.HomePage_message') },
    { name: 'mine', icon: $r('sys.symbol.person'), title: $r('app.string.HomePage_mine') }
  ];
  @Trace currentIndex: number = StorageManager.tabIndexModel.homeTabIndex;
  @Trace controller: TabsController = new TabsController();
  @Trace isInputOverlayOpen: boolean = false;
  private navHideTimerId: number = -1;
  private readonly listenerManager: ListenerManager = new ListenerManager();
  private readonly inputOverlayListener = (visible: boolean): void => {
    this.isInputOverlayOpen = visible;
  };

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
    this.registerListeners();
    this.syncStoredIndex();
    this.scheduleHideNavigation();
  }
  
  aboutToDisappear() {
    this.listenerManager.clear();
    this.isInputOverlayOpen = false;
    this.clearHideNavigationTimer();
  }

  changeNavBar(index: number) {
    if (index < 0 || index >= this.homeNavBarItem.length) {
      return;
    }
    if (this.currentIndex === index) {
      return;
    }
    this.currentIndex = index;
    StorageManager.tabIndexModel.homeTabIndex = index;
  }

  private registerListeners(): void {
    this.listenerManager.register('inputOverlay', () => {
      InputOverlayStore.on(InputOverlayVisibilityEvent, this.inputOverlayListener);
    }, () => {
      InputOverlayStore.off(InputOverlayVisibilityEvent, this.inputOverlayListener);
    });
  }

  private scheduleHideNavigation(): void {
    this.clearHideNavigationTimer();
    this.navHideTimerId = setTimeout(() => {
      this.window.showNavigation = false;
      this.navHideTimerId = -1;
    }, 50);
  }

  private clearHideNavigationTimer(): void {
    if (this.navHideTimerId !== -1) {
      clearTimeout(this.navHideTimerId);
      this.navHideTimerId = -1;
    }
  }

  private syncStoredIndex(): void {
    const storedIndex = StorageManager.tabIndexModel.homeTabIndex;
    if (storedIndex < 0 || storedIndex >= this.homeNavBarItem.length) {
      StorageManager.tabIndexModel.homeTabIndex = 0;
      this.currentIndex = 0;
      return;
    }
    this.currentIndex = storedIndex;
  }
}
