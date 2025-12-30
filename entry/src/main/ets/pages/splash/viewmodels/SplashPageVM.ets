import { AppUtil, LogUtil } from '@pura/harmony-utils';
import { AuthApi, BaseVM, BreakPointUtil, RouterMap, RouterUtil, StorageManager } from 'base_common';

const TAG = '[SplashPageVM]: ';

@ObservedV2
export class SplashPageVM extends BaseVM {
  @Trace countDown: number = 3;
  bpUtil: BreakPointUtil | null = null;
  private timerId: number = -1;

  /**
   * 开始启动流程
   */
  startSplash() {
    this.bpUtil = new BreakPointUtil(AppUtil.getUIContext().getMediaQuery());
    this.bpUtil?.register();
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
  async jumpToNext() {
    this.stopSplash();

    // 获取全局 AuthModel 并检查登录状态
    const authModel = StorageManager.authModel;

    LogUtil.debug(TAG, JSON.stringify(authModel));

    if (authModel.username && authModel.password) {
      try {
        // 尝试使用存储的密码自动登录以获取最新凭证
        await AuthApi.getInstance().login(authModel.username, authModel.password);
        // 登录成功，跳转首页
        RouterUtil.replacePathByName(RouterMap.HOME);
      } catch (e) {
        LogUtil.warn(TAG, '启动页自动登录失败，跳转登录页');
        RouterUtil.replacePathByName(RouterMap.LOGIN);
      }
    } else {
      // 未登录/无密码记录 -> 跳转登录页
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