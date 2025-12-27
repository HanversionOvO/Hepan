import { BaseVM } from "base_common";

@ObservedV2
export class LoginPageVM extends BaseVM {
  @Trace username: string = "";
  @Trace password: string = "";

  startLogin() {
    setTimeout(() => {
      this.window.showNavigation = false
    }, 50)
  }
}