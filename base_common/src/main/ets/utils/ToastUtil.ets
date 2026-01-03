import { AppUtil, LogUtil } from '@pura/harmony-utils';
import { CommonConstant } from '../constants/CommonConstant';
import { ComponentContent } from '@kit.ArkUI';
// [新增] 引入 Lottie
import { LottieView } from '@ohos/lottie-turbo';

const TAG = '[ToastUtil]: ';

export enum ToastShowType {
  OPEN,
  LOADING // [新增]
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

@Builder
function CommonToastBuilder(params: ToastParams) {
  // [关键修改] 针对 LOADING 状态使用完全独立的布局结构
  if (params.state === ToastState.LOADING) {
    Column() {
      // 1. Lottie 动画区域
      LottieView({
        lottieId: 'toast_loading', // 唯一的 ID
        path: $rawfile('loading_lottie.json'), // 确保该文件在 base_common 的 rawfile 中
        // 默认 autoPlay: true, loop: true
      })
        .width(120) // 调整 Lottie 大小
        .height(120)

      // 2. 文字区域
      if (params.message) {
        Text(params.message)
          .fontSize(CommonConstant.TextSizeNormal)
          .fontColor($r('sys.color.font_secondary')) // 或使用 Color.White 如果背景很深
          .textAlign(TextAlign.Center)
          .margin({ top: CommonConstant.SmallContainerTBPadding })
          .maxLines(2)
          .offset({ y: -20 })
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .width(160) // [需求] 固定宽度
    .height(160) // [需求] 固定高度
    .justifyContent(FlexAlign.Center) // [需求] 内容居中
    .backgroundColor($r('sys.color.comp_background_primary')) // 背景色
    .borderRadius(CommonConstant.RadiusLarge)
    .shadow(ShadowStyle.OUTER_DEFAULT_MD) // 可选：添加一点阴影增加层次感
  } else {
    // ================= 原有逻辑 (非 Loading 状态) =================
    Column() {
      // 1. 顶部图标区域 (Header)
      Stack({ alignContent: Alignment.Center }) {
        // 背景层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(ToastUtil.getIcon(params.state).color)
          .opacity(0.2)

        // 图标层
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

      // 2. 内容区域
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

      // 3. 按钮区域
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
    const state = options?.state ?? ToastState.INFO;
    const isShowConfirm = options?.isShowConfirm ?? false;

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
      state: state,
      message: message,
      isShowConfirm: isShowConfirm,
      title: options?.title,
      onCancel: safeOnCancel,
      onConfirm: safeOnConfirm
    };

    const componentContent = new ComponentContent(uiContext, WrappedToastBuilder, params);

    const prompt = uiContext.getPromptAction();
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

    const info: ToastModel = {
      com: componentContent,
      popType: type
    };
    ToastUtil.shareInstance().infoList.push(info);
  }

  static closeToast(type: ToastShowType = ToastShowType.OPEN): void {
    const uiContext = AppUtil.getUIContext();
    if (!uiContext) {
      return;
    }

    const instance = ToastUtil.shareInstance();
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
}