import { AuthApi, BaseVM, RouterMap, RouterUtil, StorageManager, ToastUtil } from 'base_common';

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
      return;
    }

    try {
      const result = await this.authApi.login(this.username.trim(), this.password);
      const authModel = StorageManager.authModel;
      authModel.authorization = result.authorization;
      authModel.cookie = result.cookie;
      authModel.uid = result.uid;
      authModel.username = result.username;

      ToastUtil.showSuccess(`欢迎回来, ${result.username}`);

      this.showSuccess();
      RouterUtil.replacePathByName(RouterMap.HOME);
    } catch (error) {
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