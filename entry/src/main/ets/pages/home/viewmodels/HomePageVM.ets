import { LogUtil } from '@pura/harmony-utils';
import { BaseVM, RouterMap, RouterUtil, StorageManager, ToastUtil, UserApi } from 'base_common';
import { HomeNavBarItem } from '../components/HomeNavBar';
import { JSON } from '@kit.ArkTS';

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

  startHome() {
    setTimeout(() => {
      this.window.showNavigation = false
    }, 50)
  }

  changeNavBar(index: number) {
    this.currentIndex = index;
  }
}