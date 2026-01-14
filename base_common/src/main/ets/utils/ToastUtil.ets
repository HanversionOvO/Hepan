import { AppUtil, LogUtil } from '@pura/harmony-utils';
import { CommonConstant } from '../constants/CommonConstant';
import { ComponentContent } from '@kit.ArkUI';
// [新增] 引入 Lottie
import { LottieView } from '@ohos/lottie-turbo';

const TAG = '[ToastUtil]: ';
const LIGHT_TOAST_VISIBLE_KEY = 'lightToastVisible';

export enum ToastShowType {
  OPEN,
  LOADING, // [新增]
  LIGHT
}

export enum ToastState {
  SUCCESS,
  WARNING,
  ERROR,
  INFO,
  LOADING // [新增]
}

export interface ToastOptions {
  type?: ToastShowType;
  state?: ToastState;
  isShowConfirm?: boolean;
  title?: ResourceStr;
  onCancel?: () => void;
  onConfirm?: () => void;
}

export interface ToastParams {
  type: ToastShowType;
  state: ToastState;
  message: ResourceStr;
  isShowConfirm: boolean;
  title?: ResourceStr;
  onCancel?: () => void;
  onConfirm?: () => void;
}

interface ToastModel {
  com: ComponentContent<ToastParams>;
  popType: ToastShowType;
}

interface ToastIcon {
  icon: Resource;
  color: ResourceColor;
}

@Component
struct LightToastView {
  @StorageLink(LIGHT_TOAST_VISIBLE_KEY) isVisible: boolean = false;
  public params: ToastParams = {
    type: ToastShowType.LIGHT,
    state: ToastState.INFO,
    message: '',
    isShowConfirm: false
  };

  build() {
    Row({ space: CommonConstant.NormalContainerInnerPadding / 2 }) {
      SymbolGlyph(ToastUtil.getIcon(this.params.state).icon)
        .fontSize(CommonConstant.TextSizeTiny)
        .fontWeight(FontWeight.Bolder)
        .fontColor([$r('sys.color.font_on_primary')])
        .borderRadius(CommonConstant.RadiusRound)
        .padding(CommonConstant.SmallContainerInnerPadding)
        .backgroundColor(ToastUtil.getIcon(this.params.state).color)

      Text(this.params.message)
        .fontSize(CommonConstant.TextSizeSmall)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
    }
    .padding({
      left: CommonConstant.SmallContainerLRPadding,
      right: CommonConstant.SmallContainerLRPadding,
      top: CommonConstant.SmallContainerTBPadding,
      bottom: CommonConstant.SmallContainerTBPadding
    })
    .borderRadius(CommonConstant.RadiusNormal)
    .backgroundColor($r('app.color.start_window_background'))
    .alignItems(VerticalAlign.Center)
    .shadow(ShadowStyle.OUTER_DEFAULT_MD)
    .translate({ x: 0, y: this.isVisible ? 0 : 20 })
    .scale({ x: this.isVisible ? 1 : 0.9, y: this.isVisible ? 1 : 0.9 })
    .opacity(this.isVisible ? 1 : 0)
    .animation({ curve: CommonConstant.AnimationCurveSpring, duration: CommonConstant.AnimationDurationNormal })
    .hitTestBehavior(HitTestMode.None)
  }
}

@Builder
function CommonToastBuilder(params: ToastParams) {
  if (params.type === ToastShowType.LIGHT) {
    LightToastView({ params })
  } else if (params.state === ToastState.LOADING) {
    Column() {
      LottieView({
        lottieId: 'toast_loading',
        path: $rawfile('loading_lottie.json')
      })
        .width(120)
        .height(120)

      if (params.message) {
        Text(params.message)
          .fontSize(CommonConstant.TextSizeNormal)
          .fontColor($r('sys.color.font_secondary'))
          .textAlign(TextAlign.Center)
          .margin({ top: CommonConstant.SmallContainerTBPadding })
          .maxLines(2)
          .offset({ y: -20 })
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .width(160)
    .height(160)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(CommonConstant.RadiusLarge)
    .shadow(ShadowStyle.OUTER_DEFAULT_MD)
  } else {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(ToastUtil.getIcon(params.state).color)
          .opacity(0.2)

        SymbolGlyph(ToastUtil.getIcon(params.state).icon)
          .fontSize(24)
          .fontColor([ToastUtil.getIcon(params.state).color])
          .fontWeight(FontWeight.Bolder)
          .padding(CommonConstant.NormalContainerInnerPadding)
          .backgroundColor($r('sys.color.font_on_primary'))
          .borderRadius(CommonConstant.RadiusRound)
      }
      .width('100%')
      .height(96)
      .flexShrink(0)

      Scroll() {
        Column({ space: CommonConstant.NormalContainerInnerPadding }) {
          if (params.title) {
            Text(params.title)
              .fontSize(CommonConstant.TextSizeLarge)
              .fontWeight(FontWeight.Bolder)
              .textAlign(TextAlign.Center)
              .width('100%')
          }

          Text(params.message)
            .fontSize(CommonConstant.TextSizeNormal)
            .fontColor($r('sys.color.font_secondary'))
            .textAlign(TextAlign.Center)
            .width('100%')
        }
        .padding({
          top: CommonConstant.NormalContainerTBPadding,
          bottom: CommonConstant.NormalContainerTBPadding,
          left: CommonConstant.NormalContainerLRPadding,
          right: CommonConstant.NormalContainerLRPadding
        })
      }
      .scrollBar(BarState.Auto)
      .width('100%')
      .constraintSize({ maxHeight: '60%' })
      .edgeEffect(EdgeEffect.Spring)

      Row({ space: CommonConstant.LargeContainerInnerPadding }) {
        ToastButton({
          bgColor: $r('sys.color.font_on_tertiary'),
          fontColor: $r('sys.color.font_secondary'),
          text: params.isShowConfirm ? $r('app.string.CommonToast_cancel') : $r('app.string.CommonToast_known'),
          clickAction: params.onCancel
        })

        if (params.isShowConfirm) {
          ToastButton({
            bgColor: ToastUtil.getIcon(params.state).color,
            fontColor: $r('sys.color.font_on_primary'),
            text: $r('app.string.CommonToast_confirm'),
            clickAction: params.onConfirm
          })
        }
      }
      .padding({
        left: CommonConstant.NormalContainerLRPadding,
        right: CommonConstant.NormalContainerLRPadding,
        top: CommonConstant.NormalContainerTBPadding,
        bottom: CommonConstant.NormalContainerTBPadding,
      })
      .width(CommonConstant.FullPercent)
      .flexShrink(0)
    }
    .width(CommonConstant.AboveHalfPercent)
    .constraintSize({ maxWidth: 400 })
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(CommonConstant.RadiusLarge)
    .clip(true)
  }
}

const WrappedToastBuilder = wrapBuilder(CommonToastBuilder);

@Component
struct ToastButton {
  public bgColor: ResourceColor = Color.White;
  public fontColor: ResourceColor = Color.Black;
  public text: ResourceStr = '';
  public clickAction?: () => void;

  build() {
    Button() {
      Text(this.text)
        .fontSize(CommonConstant.TextSizeNormal)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.fontColor)
    }
    .backgroundColor(this.bgColor)
    .padding({
      top: CommonConstant.SmallContainerTBPadding,
      bottom: CommonConstant.SmallContainerTBPadding,
    })
    .layoutWeight(1)
    .onClick(() => {
      if (this.clickAction) {
        this.clickAction();
      }
    })
  }
}

export class ToastUtil {
  private static toastShare: ToastUtil;
  private infoList: ToastModel[] = [];
  private lightTimerId: number = -1;
  private lightCloseTimerId: number = -1;

  static shareInstance(): ToastUtil {
    if (!ToastUtil.toastShare) {
      ToastUtil.toastShare = new ToastUtil();
    }
    return ToastUtil.toastShare;
  }

  static getIcon(state: ToastState): ToastIcon {
    switch (state) {
      case ToastState.SUCCESS:
        return { icon: $r('sys.symbol.checkmark'), color: CommonConstant.SuccessColor };
      case ToastState.WARNING:
        return { icon: $r('sys.symbol.warning'), color: CommonConstant.WarningColor };
      case ToastState.ERROR:
        return { icon: $r('sys.symbol.xmark'), color: CommonConstant.ErrorColor };
      // Loading 状态其实在这里不需要图标配置了，因为 builder 里直接用了 Lottie，但为了类型安全保留一个默认
      case ToastState.LOADING:
        return { icon: $r('sys.symbol.arrow_clockwise'), color: CommonConstant.InfoColor };
      default:
        return { icon: $r('sys.symbol.info_shield'), color: CommonConstant.InfoColor };
    }
  }

  // ================= 核心方法 =================

  static showToast(message: ResourceStr, options?: ToastOptions) {
    const uiContext = AppUtil.getUIContext();
    if (!uiContext) {
      LogUtil.error(TAG, 'UIContext is null');
      return;
    }

    const type = options?.type ?? ToastShowType.OPEN;
    let state = options?.state ?? ToastState.INFO;
    const isShowConfirm = options?.isShowConfirm ?? false;

    if (type === ToastShowType.LIGHT && state === ToastState.LOADING) {
      state = ToastState.INFO;
    }

    const safeOnCancel = () => {
      ToastUtil.closeToast(type);
      if (options?.onCancel) {
        options.onCancel();
      }
    };

    const safeOnConfirm = () => {
      ToastUtil.closeToast(type);
      if (options?.onConfirm) {
        options.onConfirm();
      }
    };

    const params: ToastParams = {
      type: type,
      state: state,
      message: message,
      isShowConfirm: isShowConfirm,
      title: options?.title,
      onCancel: safeOnCancel,
      onConfirm: safeOnConfirm
    };

    const componentContent = new ComponentContent(uiContext, WrappedToastBuilder, params);

    const prompt = uiContext.getPromptAction();
    if (type === ToastShowType.LIGHT) {
      ToastUtil.closeToast(ToastShowType.LIGHT, true);
      const instance = ToastUtil.shareInstance();
      if (instance.lightTimerId !== -1) {
        clearTimeout(instance.lightTimerId);
        instance.lightTimerId = -1;
      }
      if (instance.lightCloseTimerId !== -1) {
        clearTimeout(instance.lightCloseTimerId);
        instance.lightCloseTimerId = -1;
      }
      AppStorage.setOrCreate(LIGHT_TOAST_VISIBLE_KEY, false);
      prompt.openCustomDialog(componentContent, {
        alignment: DialogAlignment.Bottom,
        offset: { dx: 0, dy: -CommonConstant.BottomBarHeight },
        isModal: false,
        maskColor: Color.Transparent,
        autoCancel: false,
        onDidAppear: () => {
          AppStorage.set(LIGHT_TOAST_VISIBLE_KEY, true);
        },
        onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
          if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
            ToastUtil.closeToast(type);
          }
        }
      }).catch((err: Error) => {
        LogUtil.error(TAG, `openCustomDialog failed. message=${err.message}`);
      });
    } else {
      prompt.openCustomDialog(componentContent, {
        alignment: DialogAlignment.Center,
        autoCancel: false, // Loading 也不允许点击背景关闭
        onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
          if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
            ToastUtil.closeToast(type);
          }
        }
      }).catch((err: Error) => {
        LogUtil.error(TAG, `openCustomDialog failed. message=${err.message}`);
      });
    }

    const info: ToastModel = {
      com: componentContent,
      popType: type
    };
    ToastUtil.shareInstance().infoList.push(info);

    if (type === ToastShowType.LIGHT) {
      const instance = ToastUtil.shareInstance();
      const delay = CommonConstant.AnimationDurationNormal + 4000;
      instance.lightTimerId = setTimeout(() => {
        ToastUtil.closeToast(ToastShowType.LIGHT);
        instance.lightTimerId = -1;
      }, delay);
    }
  }

  static closeToast(type: ToastShowType = ToastShowType.OPEN, immediate: boolean = false): void {
    const uiContext = AppUtil.getUIContext();
    if (!uiContext) {
      return;
    }

    const instance = ToastUtil.shareInstance();
    if (type === ToastShowType.LIGHT && !immediate) {
      AppStorage.setOrCreate(LIGHT_TOAST_VISIBLE_KEY, false);
      if (instance.lightCloseTimerId !== -1) {
        clearTimeout(instance.lightCloseTimerId);
      }
      instance.lightCloseTimerId = setTimeout(() => {
        ToastUtil.closeToast(type, true);
        instance.lightCloseTimerId = -1;
      }, CommonConstant.AnimationDurationNormal);
      return;
    }
    if (type === ToastShowType.LIGHT) {
      AppStorage.setOrCreate(LIGHT_TOAST_VISIBLE_KEY, false);
      if (instance.lightCloseTimerId !== -1) {
        clearTimeout(instance.lightCloseTimerId);
        instance.lightCloseTimerId = -1;
      }
      if (instance.lightTimerId !== -1) {
        clearTimeout(instance.lightTimerId);
        instance.lightTimerId = -1;
      }
    }
    // 查找对应类型的 Toast
    const index = instance.infoList.map(item => item.popType).lastIndexOf(type);

    if (index !== -1) {
      const info = instance.infoList[index];
      if (info && info.com) {
        const prompt = uiContext.getPromptAction();
        prompt.closeCustomDialog(info.com).catch((err: Error) => {
          LogUtil.error(TAG, `closeCustomDialog failed. message=${err.message}`);
        });
        instance.infoList.splice(index, 1);
      }
    }
  }

  // ================= 便捷封装方法 =================

  static showSuccess(message: ResourceStr, isShowConfirm: boolean = false, title?: ResourceStr, onConfirm?: () => void,
    onCancel?: () => void) {
    ToastUtil.showToast(message, {
      state: ToastState.SUCCESS,
      isShowConfirm: isShowConfirm,
      title: title,
      onConfirm: onConfirm,
      onCancel: onCancel
    });
  }

  static showError(message: ResourceStr, isShowConfirm: boolean = false, title?: ResourceStr, onConfirm?: () => void,
    onCancel?: () => void) {
    ToastUtil.showToast(message, {
      state: ToastState.ERROR,
      isShowConfirm: isShowConfirm,
      title: title,
      onConfirm: onConfirm,
      onCancel: onCancel
    });
  }

  static showWarn(message: ResourceStr, isShowConfirm: boolean = false, title?: ResourceStr, onConfirm?: () => void,
    onCancel?: () => void) {
    ToastUtil.showToast(message, {
      state: ToastState.WARNING,
      isShowConfirm: isShowConfirm,
      title: title,
      onConfirm: onConfirm,
      onCancel: onCancel
    });
  }

  static showInfo(message: ResourceStr, isShowConfirm: boolean = false, title?: ResourceStr, onConfirm?: () => void,
    onCancel?: () => void) {
    ToastUtil.showToast(message, {
      state: ToastState.INFO,
      isShowConfirm: isShowConfirm,
      title: title,
      onConfirm: onConfirm,
      onCancel: onCancel
    });
  }

  // [新增] 快捷调用 Loading
  static showLoading(message: ResourceStr) {
    ToastUtil.showToast(message, {
      type: ToastShowType.LOADING,
      state: ToastState.LOADING
    });
  }

  // [新增] 快捷关闭 Loading
  static hideLoading() {
    ToastUtil.closeToast(ToastShowType.LOADING);
  }

  static showLight(message: ResourceStr, state: ToastState = ToastState.INFO) {
    ToastUtil.showToast(message, {
      type: ToastShowType.LIGHT,
      state: state
    });
  }

  static showLightSuccess(message: ResourceStr) {
    ToastUtil.showLight(message, ToastState.SUCCESS);
  }

  static showLightError(message: ResourceStr) {
    ToastUtil.showLight(message, ToastState.ERROR);
  }

  static showLightWarn(message: ResourceStr) {
    ToastUtil.showLight(message, ToastState.WARNING);
  }

  static showLightInfo(message: ResourceStr) {
    ToastUtil.showLight(message, ToastState.INFO);
  }
}
