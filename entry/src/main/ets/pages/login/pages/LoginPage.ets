import { CommonConstant, VMManager } from 'base_common'
import { LoginInput } from '../components/LoginInput';
import { LoginPageVM } from '../viewmodels/LoginPageVM'

@Builder
export function LoginPageBuilder() {
  LoginPage()
}

@ComponentV2
struct LoginPage {
  @Local vm: LoginPageVM = VMManager.get(LoginPageVM, () => new LoginPageVM());
  @Local logoSize: number = 48;
  @Local maxMiddleWidth: number = 320;

  @Builder
  TopArea() {
    Column({space:CommonConstant.NormalContainerInnerPadding}){
      Image($r('app.media.startIcon'))
        .width(this.logoSize)
        .height(this.logoSize)
        .borderRadius(CommonConstant.RadiusNormal)
        
      Column({space: CommonConstant.SmallContainerInnerPadding}) {
        Text($r('app.string.Login_title'))
          .fontSize(CommonConstant.TextSizeUltraLarge)
          .fontWeight(FontWeight.Bold)
    
          Text($r('app.string.Login_subtitle'))
          .fontSize(CommonConstant.TextSizeLarge)
          .fontColor($r('sys.color.font_secondary'))
      }
    }
    .width(CommonConstant.FullPercent)
  }
  
  @Builder
  MiddleArea() {
    Column({space: CommonConstant.NormalContainerInnerPadding}) {
      LoginInput({
        placeHolder: $r("app.string.Login_login_placeHolder")
      })
      LoginInput({
        placeHolder: $r("app.string.Login_password_placeHolder"),
        isPassword: true
      })
    }
    .constraintSize({maxWidth:this.maxMiddleWidth})
  }

  build() {
    NavDestination() {
      Stack() {
        Column({space: CommonConstant.NormalContainerInnerPadding}) {
          this.TopArea()
          
          this.MiddleArea()
        }
        .width(CommonConstant.AboveHalfPercent)
        .padding({
          left: CommonConstant.NormalContainerLRPadding,
          right: CommonConstant.NormalContainerLRPadding,
          top: CommonConstant.NormalContainerTBPadding,
          bottom: CommonConstant.NormalContainerTBPadding
        })
        .borderRadius(CommonConstant.RadiusNormal)
      }
        .width(CommonConstant.FullPercent)
        .height(CommonConstant.FullPercent)
    }
      .backgroundColor($r('app.color.start_window_background'))
      .hideTitleBar(true)
      .onShown(() => {
        this.vm.startLogin();
      })
  }
}