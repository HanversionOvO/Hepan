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
      ToastUtil.showWarn($r('app.string.Login_input_warn'));
      return;
    }

    try {
      const result = await this.authApi.login(this.username.trim(), this.password);
      const authModel = StorageManager.authModel;

      // 更新内存数据
      authModel.authorization = result.authorization;
      authModel.cookie = result.cookie;
      authModel.uid = result.uid;
      authModel.username = result.username;

      // 保存到本地磁盘
      authModel.saveToDisk();

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