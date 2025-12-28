import { LogUtil } from '@pura/harmony-utils';
import { ApiClient, BaseVM, RouterMap, RouterUtil, StorageManager } from 'base_common';

const TAG = '[SplashPageVM]: ';

@ObservedV2
export class SplashPageVM extends BaseVM {
  @Trace countDown: number = 3;
  private timerId: number = -1;

  /**
   * 开始启动流程
   */
  startSplash() {
    // 避免重复启动
    if (this.timerId !== -1) {
      return;
    }

    this.timerId = setInterval(() => {
      this.countDown--;
      if (this.countDown <= 0) {
        this.jumpToNext();
      }
    }, 1000);
  }

  /**
   * 跳转逻辑 (可根据业务扩展：判断是否登录、是否同意隐私协议等)
   */
  jumpToNext() {
    this.stopSplash();

    // 获取全局 AuthModel 并检查登录状态
    const authModel = StorageManager.authModel;

    LogUtil.debug(TAG, JSON.stringify(authModel));

    if (authModel.isLoggedIn) {
      ApiClient.getInstance().setAuthorization(authModel.authorization);
      RouterUtil.replacePathByName(RouterMap.HOME);
    } else {
      // 未登录 -> 跳转登录页
      RouterUtil.replacePathByName(RouterMap.LOGIN);
    }
  }

  /**
   * 停止倒计时并清理资源
   */
  stopSplash() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  /**
   * 用户点击"跳过"
   */
  onSkip() {
    this.jumpToNext();
  }
}