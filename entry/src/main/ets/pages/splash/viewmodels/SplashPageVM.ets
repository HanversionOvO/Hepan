import { BaseVM, RouterMap, RouterUtil } from 'base_common';

@ObservedV2
export class SplashPageVM extends BaseVM {
  @Trace countDown: number = 3;
  private timerId: number = -1;


  /**
   * 开始启动流程
   */
  startSplash() {
    // 避免重复启动
    if (this.timerId !== -1) return;

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

    // 示例：判断是否登录 (假设 globalStore 中有相关状态)
    // if (this.globalStore.isLogin) { ... }

    // 使用 replacePathByName，销毁当前 Splash 页面，不可返回
    // 注意：请确保 RouterMap.HOME 已在 RouterUtil 中定义
    // RouterUtil.replacePathByName(RouterMap.SPLASH);
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