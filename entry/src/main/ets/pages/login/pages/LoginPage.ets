import { CommonConstant, VMManager } from 'base_common';
import { LoginButton } from '../components/LoginButton';
import { LoginInput } from '../components/LoginInput';
import { LoginPageVM } from '../viewmodels/LoginPageVM';
import { inputMethod } from '@kit.IMEKit';
import { LogUtil } from '@pura/harmony-utils';

const TAG = '[LoginPage]: '

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
    Column({ space: CommonConstant.NormalContainerInnerPadding }) {
      Image($r('app.media.startIcon'))
        .width(this.logoSize)
        .height(this.logoSize)
        .borderRadius(CommonConstant.RadiusNormal)

      Column({ space: CommonConstant.SmallContainerInnerPadding }) {
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
    Column({ space: CommonConstant.NormalContainerInnerPadding }) {
      LoginInput({
        icon: $r('sys.symbol.person'),
        placeHolder: $r("app.string.Login_login_placeHolder"),
        value: this.vm.username,
        $value: (val: string) => {
          this.vm.username = val
        }
      })
      LoginInput({
        icon: $r('sys.symbol.lock'),
        placeHolder: $r("app.string.Login_password_placeHolder"),
        isPassword: true,
        value: this.vm.password,
        $value: (val: string) => {
          this.vm.password = val
        }
      })

      Row() {
        Text($r('app.string.Login_unable_login'))
          .fontSize(CommonConstant.TextSizeSmall)
          .fontColor($r('sys.color.font_secondary'))

        Text($r('app.string.Login_register'))
          .fontSize(CommonConstant.TextSizeSmall)
          .fontColor($r('sys.color.font_secondary'))
      }
      .width(CommonConstant.FullPercent)
      .justifyContent(FlexAlign.SpaceBetween)

      LoginButton()
        .onClick(() => {
          this.vm.handleLogin();
        })
    }
  }

  @Builder
  BottomArea() {
    Row({ space: CommonConstant.SmallContainerTBPadding }) {
      Row({ space: CommonConstant.SmallContainerInnerPadding }) {
        Divider()
          .vertical(false)
          .width(24)
          .color($r('sys.color.font_secondary'))

        Text($r('app.string.Login_other_logins'))
          .fontSize(CommonConstant.TextSizeSmall)
          .fontColor($r('sys.color.font_tertiary'))

        Divider()
          .vertical(false)
          .width(24)
          .color($r('sys.color.font_secondary'))
      }
    }
  }

  build() {
    NavDestination() {
      Stack() {

        Column({ space: CommonConstant.NormalContainerInnerPadding }) {
          this.TopArea()

          this.MiddleArea()

          this.BottomArea()
        }
        .backgroundColor($r('app.color.start_window_background'))
        .width(CommonConstant.AboveHalfPercent)
        .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
        .constraintSize({ maxWidth: this.maxMiddleWidth })
        .padding(CommonConstant.LargeContainerLRPadding)
        .borderRadius(CommonConstant.RadiusNormal)
      }
      .backgroundImage("https://gips2.baidu.com/it/u=2055042668,1190219470&fm=3028&app=3028&f=JPEG&fmt=auto?w=960&h=1280")
      .backgroundImageSize(ImageSize.Cover)
      .backgroundImagePosition(Alignment.Center)
      .backgroundBlurStyle(BlurStyle.Thin)
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
      .onClick(() => {
        // [新增] 点击背景区域关闭软键盘
        try {
          inputMethod.getController().hideTextInput();
        } catch (err) {
          LogUtil.error(TAG, 'Failed to hideTextInput. Cause: ' + JSON.stringify(err));
        }
      })
    }
    .backgroundColor($r('app.color.start_window_background'))
    .hideTitleBar(true)
    .animation({
      duration: CommonConstant.AnimationDurationNormal
    })
    .onShown(() => {
      this.vm.startLogin();
    })
  }
}