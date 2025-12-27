import { VMManager } from 'base_common'
import { LoginPageVM } from '../viewmodels/LoginPageVM'

@Builder
export function LoginPageBuilder() {
  LoginPage()
}

@ComponentV2
struct LoginPage {
  @Local vm: LoginPageVM = VMManager.get(LoginPageVM, () => new LoginPageVM());

  build() {
    NavDestination()
      .hideTitleBar(true)
  }
}