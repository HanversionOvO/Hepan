import { BaseVM } from "base_common";

@ObservedV2
export class LoginPageVM extends BaseVM {
  startLogin() {
    setTimeout(() => {
      this.window.showNavigation = false
    }, 50)
  }
}