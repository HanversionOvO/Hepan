import { BaseVM, RouterUtil, StorageManager } from 'base_common';
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

  @Computed
  get isNavBarVisible(): boolean {
    if (this.isTabletView) {
      return true;
    }

    if (this.currentIndex === 0 || this.currentIndex === 3) {
      return true;
    }

    if (RouterUtil.routerModel.messageStackSize > 0) {
      return false;
    }

    return true;
  }

  startHome() {
    setTimeout(() => {
      this.window.showNavigation = false
    }, 50)
  }

  changeNavBar(index: number) {
    this.currentIndex = index;
  }
}