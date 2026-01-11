import { AppUtil, LogUtil } from '@pura/harmony-utils';
import { AuthApi, BaseVM, BreakPointUtil, RouterMap, RouterUtil, StorageManager } from 'base_common';

const TAG = '[SplashPageVM]: ';

@ObservedV2
export class SplashPageVM extends BaseVM {
  @Trace countDown: number = 3;
  @Trace isEnabled: boolean = true;
  bpUtil: BreakPointUtil | null = null;
  private timerId: number = -1;
  private isNavigating: boolean = false;
  private isCheckingLogin: boolean = false;
  private isCountdownFinished: boolean = false;
  private pendingRoute: string | null = null;

  /**
   * 开始启动流程
   */
  startSplash() {
    this.bpUtil = new BreakPointUtil(AppUtil.getUIContext().getMediaQuery());
    this.bpUtil?.register();
    this.isCountdownFinished = false;
    this.pendingRoute = null;
    // 避免重复启动
    if (this.timerId === -1) {
      this.timerId = setInterval(() => {
        this.countDown--;
        if (this.countDown <= 0) {
          this.jumpToNext();
        }
      }, 1000);
    }

    // 进入启动页后立即检查登录并尝试自动登录（与倒计时并行）
    this.startLoginCheck();
  }

  /**
   * 跳转逻辑 (可根据业务扩展：判断是否登录、是否同意隐私协议等)
   */
  async jumpToNext() {
    if (this.isNavigating) {
      return;
    }
    this.isCountdownFinished = true;
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    if (this.pendingRoute) {
      this.navigateTo(this.pendingRoute);
    }
  }

  private startLoginCheck() {
    if (this.isCheckingLogin || this.isNavigating) {
      return;
    }
    this.isCheckingLogin = true;
    this.checkLoginAndNavigate().catch((error: Error) => {
      LogUtil.error(TAG, '启动页登录检查异常', JSON.stringify(error));
    });
  }

  private async checkLoginAndNavigate() {
    try {
      // 获取全局 AuthModel 并检查登录状态
      const authModel = StorageManager.authModel;

      LogUtil.debug(TAG, JSON.stringify(authModel));

      if (authModel.username && authModel.password) {
        try {
          // 尝试使用存储的密码自动登录以获取最新凭证
          await AuthApi.getInstance().login(authModel.username, authModel.password);
          // 登录成功，跳转首页
          this.pendingRoute = RouterMap.HOME;
        } catch (e) {
          LogUtil.warn(TAG, '启动页自动登录失败，跳转登录页');
          this.pendingRoute = RouterMap.LOGIN;
        }
      } else {
        // 未登录/无密码记录 -> 跳转登录页
        this.pendingRoute = RouterMap.LOGIN;
      }
    } finally {
      this.isCheckingLogin = false;
      if (this.isCountdownFinished && this.pendingRoute) {
        this.navigateTo(this.pendingRoute);
      }
    }
  }

  private navigateTo(target: string) {
    if (this.isNavigating) {
      return;
    }
    this.isNavigating = true;
    this.stopSplash();
    RouterUtil.replacePathByName(target);
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
