import { CommonConstant, RouterMap, RouterUtil } from 'base_common';

/**
 * 一镜到底预览跳转参数接口
 */
export interface LongTakePreviewOptions {
  /**
   * UI上下文，用于执行动画
   */
  uiContext: UIContext;

  /**
   * 共享元素转场的 ID
   */
  componentId: string;

  /**
   * 预览图片列表
   */
  imageList: string[];

  /**
   * 初始选中的图片索引，默认为 0
   */
  selectedIndex?: number;

  /**
   * 跳转动作触发时的回调（通常用于隐藏当前页面的原始组件）
   */
  onShowAction?: () => void;

  /**
   * 从预览页返回时的回调（通常用于恢复显示当前页面的原始组件）
   */
  onBackToFirstPage?: () => void;
}

/**
 * 一镜到底图片预览工具类
 */
export class ImageLongTakePreviewUtil {
  /**
   * 打开一镜到底预览页
   */
  public static show(options: LongTakePreviewOptions): void {
    // 1. 构造路由参数
    let param: Record<string, Object> = {};
    param.componentId = options.componentId;
    param.imageList = options.imageList;
    param.selectedIndex = options.selectedIndex ?? 0;

    // 2. 封装返回回调
    param.onBackToFirstPage = () => {
      if (options.onBackToFirstPage) {
        options.onBackToFirstPage();
      }
    };

    // 3. 执行共享元素转场动画并跳转
    options.uiContext.animateTo({
      duration: CommonConstant.AnimationDurationNormal,
      curve: CommonConstant.AnimationCurveSpring,
    }, () => {
      RouterUtil.pushPathByName(RouterMap.IMAGE_LONG_TAKE_PREVIEW, param, () => {
      }, false);
    });

    // 4. 触发显示动作（如隐藏原图）
    if (options.onShowAction) {
      options.onShowAction();
    }
  }
}