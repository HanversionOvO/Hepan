import { AuthApi, BaseVM, RouterMap, RouterUtil, ToastUtil } from 'base_common';

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
      await this.authApi.login(this.username.trim(), this.password);

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
