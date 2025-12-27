import { curves } from "@kit.ArkUI";

export class CommonConstant {
  // 尺寸相关
  // 控件尺寸
  static readonly FullPercent: string = "100%"; // 全尺寸
  // 文字尺寸
  static readonly TextSizeUltraTiny: number = 8; // 超微小文字大小
  static readonly TextSizeTiny: number = 10; // 微小文字大小
  static readonly TextSizeSmall: number = 12; // 小文字大小
  static readonly TextSizeNormal: number = 14; // 普通文字大小
  static readonly TextSizeLarge: number = 16; // 大文字大小
  static readonly TextSizeUltraLarge: number = 20; // 超大文字大小
  // 圆角尺寸
  static readonly RadiusTiny: number = 4;
  static readonly RadiusSmall: number = 6;
  static readonly RadiusNormal: number = 8;
  static readonly RadiusLarge: number = 10;
  static readonly RadiusUltraLarge: number = 12;
  static readonly RadiusRound: string = "50%";
  // 边框尺寸
  static readonly BorderSizeTiny: number = 0.2;
  static readonly BorderSizeSmall: number = 0.5;
  static readonly BorderSizeNormal: number = 1;
  static readonly BorderSizeLarge: number = 2;
  static readonly BorderSizeHuge: number = 4;
  // 顶/底栏尺寸
  static readonly TopBarHeight: number = 54;
  static readonly BottomBarHeight: number = 60;

  // 间隔相关
  // 小型容器内部间隔
  static readonly SmallContainerInnerPadding: number = 4; // 容器内部控件间隔
  static readonly SmallContainerLRPadding: number = 14; // 小型容器内部左右间隔
  static readonly SmallContainerTBPadding: number = 8; // 小型容器内部上下间隔
  // 普通容器内容间隔
  static readonly NormalContainerInnterPadding: number = 12; // 普通容器内容间隔
  // 页面内部间隔
  static readonly PageLRPadding: number = 18; // 页面左右间隔

  // 动画相关
  // 动画速度
  static readonly AnimationDurationUltraFast: number = 100;
  static readonly AnimationDurationFast: number = 200;
  static readonly AnimationDurationNormal: number = 300;
  static readonly AnimationDurationSlow: number = 400;
  static readonly AnimationDurationUltraSlow: number = 600;
  // 动画曲线
  static readonly AnimationCurveNormal: Curve = Curve.EaseInOut;
  static readonly AnimationCurveSpring: curves.ICurve = curves.springMotion(0.4, 0.8);
  // 按压缩放尺寸
  static readonly PressedDownScaleNormal: number = 0.9;
}