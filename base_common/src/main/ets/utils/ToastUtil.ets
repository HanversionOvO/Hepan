import { AppUtil, LogUtil } from '@pura/harmony-utils';
import { CommonConstant } from '../constants/CommonConstant';
import { ComponentContent } from '@kit.ArkUI';

const TAG = '[ToastUtil]: ';

export enum ToastShowType {
  OPEN
}

export enum ToastState {
  SUCCESS,
  WARNING,
  ERROR,
  INFO
}

export interface ToastOptions {
  type?: ToastShowType;
  state?: ToastState;
  isShowConfirm?: boolean;
  title?: string;
  onCancel?: () => void;
  onConfirm?: () => void;
}

export interface ToastParams {
  state: ToastState;
  message: string;
  isShowConfirm: boolean;
  title?: string;
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
  Column() { // 移除 space，改由内部 Padding 控制布局，以消除顶部间隙
    // 1. 顶部图标区域 (Header)
    Stack({ alignContent: Alignment.Center }) {
      // 背景层：填充并设置透明度
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
    .height(96) // 固定高度
    .flexShrink(0) // 防止被压缩

    // 2. 内容区域 (Scrollable Body)
    // 使用 Scroll 包裹内容，并限制最大高度
    Scroll() {
      Column({ space: CommonConstant.SmallContainerInnerPadding }) {
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
    // [关键修复] 限制滚动区域的最大高度 (例如屏幕高度的 60%)
    // 这样内容少时自适应，多时滚动
    .constraintSize({ maxHeight: '60%' })
    .edgeEffect(EdgeEffect.Spring) // 添加回弹效果优化体验

    // 3. 按钮区域 (Footer)
    Row({ space: CommonConstant.NormalContainerInnerPadding }) {
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
      bottom: CommonConstant.NormalContainerTBPadding,
      // 顶部留一点间距，或者由 Scroll 的 padding.bottom 处理
    })
    .width(CommonConstant.FullPercent)
    .flexShrink(0) // 防止被压缩
  }
  .width(CommonConstant.AboveHalfPercent)
  .constraintSize({ maxWidth: 400 })
  .backgroundColor($r('sys.color.comp_background_primary'))
  .borderRadius(CommonConstant.RadiusLarge)
  .clip(true) // [关键修复] 裁剪子元素，确保顶部背景色块不会溢出圆角
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
      default:
        return { icon: $r('sys.symbol.info_shield'), color: CommonConstant.InfoColor };
    }
  }

  // ================= 核心方法 =================

  static showToast(message: string, options?: ToastOptions) {
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
      autoCancel: false,
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

  static showSuccess(message: string, isShowConfirm: boolean = false, title?: string, onConfirm?: () => void,
    onCancel?: () => void) {
    ToastUtil.showToast(message, {
      state: ToastState.SUCCESS,
      isShowConfirm: isShowConfirm,
      title: title,
      onConfirm: onConfirm,
      onCancel: onCancel
    });
  }

  static showError(message: string, isShowConfirm: boolean = false, title?: string, onConfirm?: () => void,
    onCancel?: () => void) {
    ToastUtil.showToast(message, {
      state: ToastState.ERROR,
      isShowConfirm: isShowConfirm,
      title: title,
      onConfirm: onConfirm,
      onCancel: onCancel
    });
  }

  static showWarn(message: string, isShowConfirm: boolean = false, title?: string, onConfirm?: () => void,
    onCancel?: () => void) {
    ToastUtil.showToast(message, {
      state: ToastState.WARNING,
      isShowConfirm: isShowConfirm,
      title: title,
      onConfirm: onConfirm,
      onCancel: onCancel
    });
  }

  static showInfo(message: string, isShowConfirm: boolean = false, title?: string, onConfirm?: () => void,
    onCancel?: () => void) {
    ToastUtil.showToast(message, {
      state: ToastState.INFO,
      isShowConfirm: isShowConfirm,
      title: title,
      onConfirm: onConfirm,
      onCancel: onCancel
    });
  }
}