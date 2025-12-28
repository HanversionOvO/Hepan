import { AuthApi, BaseVM, StorageManager, RouterUtil, RouterMap } from "base_common";

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

      this.showSuccess();
      RouterUtil.replacePathByName(RouterMap.HOME);
    } catch (error) {
      this.showError();
    }
  }
}