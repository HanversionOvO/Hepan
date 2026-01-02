import { AuthApi, BaseVM, MessageManager, RouterMap, RouterUtil, ToastUtil } from 'base_common';

const TAG = '[LoginPageVM]: ';

@ObservedV2
export class LoginPageVM extends BaseVM {
  @Trace username: string = "";
  @Trace password: string = "";
  private authApi: AuthApi = AuthApi.getInstance();

  startLogin() {
    setTimeout(() => {
      this.window.showNavigation = false
    }, 50)
  }

  async handleLogin() {
    if (!this.username || !this.password) {
      ToastUtil.showWarn($r('app.string.Login_input_warn'));
      return;
    }

    try {
      // 2. 调用登录接口
      // 注意：现在的 AuthApi.login 内部会自动更新 AuthModel 并将账号密码持久化到本地
      // 所以这里不再需要手动操作 StorageManager.authModel
      await this.authApi.login(this.username.trim(), this.password);

      MessageManager.getInstance().start();

      // 3. 登录成功处理
      this.showSuccess();
      RouterUtil.replacePathByName(RouterMap.HOME);

    } catch (error) {
      // 4. 登录失败处理
      let message = '';
      if (error instanceof Error) {
        message = error.message;
      } else if (typeof error === 'string') {
        message = error;
      }

      ToastUtil.showError(message, false, $r('app.string.Login_failed_title'));
      this.showError();
    }
  }
}