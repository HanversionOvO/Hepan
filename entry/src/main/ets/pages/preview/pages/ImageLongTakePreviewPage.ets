import { CommonConstant } from 'base_common';
import { ImageLongTakeDelegate } from 'base_ui';

// 页面构建函数，需要在 router_map.json 中注册
@Builder
export function ImageLongTakePreviewPageBuilder() {
  ImageLongTakePreviewPage();
}

@ComponentV2
export struct ImageLongTakePreviewPage {
  @Local componentId: string = '';
  @Local imageList: string[] = [];
  @Local pageInfos: NavPathStack = new NavPathStack();
  @Local selectedIndex: number = 0;
  @Local bgOpacity: number = 0;
  @Local bgBlurStyle: BlurStyle = BlurStyle.NONE;
  // 回调函数：通知上一个页面恢复显示（如果需要）
  private onBackToFirstPage: () => void = () => {
  };
  private readonly maxBlurRadius: number = 20;
  // 返回上一页的逻辑
  backToFirstPage: () => void = () => {
    this.getUIContext().animateTo({
      duration: CommonConstant.AnimationDurationNormal,
      curve: CommonConstant.AnimationCurveSpring,
    }, () => {
      this.bgOpacity = 0;
      this.onBackToFirstPage();
      this.pageInfos.pop(false);
    })
  }

  updateBackgroundByScale(scale: number): void {
    const clampScale = Math.min(1, Math.max(0, scale));
    this.bgOpacity = clampScale;
  }

  build() {
    NavDestination() {
      Stack() {
        Column()
          .width(CommonConstant.FullPercent)
          .height(CommonConstant.FullPercent)
          .backgroundColor($r('app.color.glass_background'))
          .backgroundBlurStyle(this.bgBlurStyle)
          .opacity(this.bgOpacity)
        Swiper() {
          ForEach(this.imageList, (item: string, index: number) => {
            // 使用封装好的一镜到底手势组件
            ImageLongTakeDelegate({
              componentId: this.componentId,
              imageUrl: item,
              backToFirstPage: () => {
                this.backToFirstPage();
              },
              onPullingScaleChange: (scale: number) => {
                this.updateBackgroundByScale(scale);
              },
            })
          }, (item: string) => item)
        }
        .transition(TransitionEffect.opacity(0.99))
        .width(CommonConstant.FullPercent)
        .height(CommonConstant.FullPercent)
        .clip(false)
        .index(this.selectedIndex)
        .indicator(false)
        .loop(false) // 预览通常不循环，可视需求开启
        .onChange((index: number) => {
          this.selectedIndex = index;
        })
      }
    }
    .mode(NavDestinationMode.DIALOG) // 设置为 Dialog 模式，背景透明
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.backToFirstPage();
      return true;
    })
    .onReady((navDestContext: NavDestinationContext) => {
      this.pageInfos = navDestContext.pathStack;
      // 获取路由传递的参数
      let param = navDestContext.pathInfo?.param as Record<string, Object>;
      if (param) {
        this.componentId = param.componentId as string;
        this.imageList = param.imageList as string[];
        this.selectedIndex = param.selectedIndex as number ?? 0;
        this.onBackToFirstPage = param.onBackToFirstPage as () => void ?? (() => {
        });
      }

      this.bgOpacity = 0;
      this.bgBlurStyle = BlurStyle.NONE;

      setTimeout(() => {
        this.getUIContext().animateTo({
          duration: CommonConstant.AnimationDurationNormal,
          curve: CommonConstant.AnimationCurveSpring,
        }, () => {
          this.bgOpacity = 1;
          this.bgBlurStyle = BlurStyle.BACKGROUND_ULTRA_THICK;
        })
      }, 1)
    })
  }
}