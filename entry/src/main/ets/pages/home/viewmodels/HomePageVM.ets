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

    // 1. 检查是否登录
    this.checkLoginAndFetchInfo();
  }

  /**
   * 检查登录状态并获取用户信息
   */
  private checkLoginAndFetchInfo() {
    const authModel = StorageManager.authModel;

    // 如果未登录 (无Authorization或Cookie)
    if (!authModel.isLoggedIn) {
      ToastUtil.showError($r('app.string.Home_please_login_content'), false, $r('app.string.Home_please_login_title'));
      RouterUtil.replacePathByName(RouterMap.LOGIN);
      return;
    }

    this.fetchUserInfo(authModel.uid);
  }

  /**
   * 异步获取用户信息并更新 Model
   */
  private async fetchUserInfo(uid: number) {
    if (uid === 0) {
      // 异常情况：已登录但无UID，尝试用 'me' 或重新登录
      LogUtil.warn(TAG, 'UID is 0, skipping fetch.');
      return;
    }

    const data = await UserApi.getUserProfile(uid);
    if (data && data.user_summary) {
      // 更新全局用户模型
      StorageManager.userModel.setUserProfile(data);
      LogUtil.debug(TAG, `Fetched user info successful: \n ${JSON.stringify(data.user_summary)}`)
    } else {
      // 获取失败可选策略：提示用户或静默失败
      LogUtil.warn(TAG, 'Failed to fetch user info.');
    }
  }

  changeNavBar(index: number) {
    this.currentIndex = index;
  }
}