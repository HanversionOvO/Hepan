import { CommonConstant } from 'base_common';
import { FloatButton, ImageButtonOption, ImageLongTakeDelegate } from 'base_ui';

// 页面构建函数，需要在 router_map.json 中注册
@Builder
export function ImageLongTakePreviewPageBuilder() {
  ImageLongTakePreviewPage();
}

@ComponentV2
export struct ImageLongTakePreviewPage {
  @Local componentId: string = '';
  @Local imageList: string[] = [];
  @Local buttons: ImageButtonOption[] = [];
  @Local pageInfos: NavPathStack = new NavPathStack();
  @Local selectedIndex: number = 0;
  @Local hideIndicator: boolean = false;
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

  @Builder
  Indicator() {
    Row() {
      Text(`${this.selectedIndex + 1}/${this.imageList.length}`)
        .fontSize(CommonConstant.TextSizeSmall)
        .fontWeight(FontWeight.Bold)
    }
    .height(CommonConstant.IconSizeLarge)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .padding({
      left: CommonConstant.SmallContainerLRPadding,
      right: CommonConstant.SmallContainerLRPadding
    })
    .borderRadius(CommonConstant.RadiusRound)
    .backgroundColor($r('app.color.glass_background'))
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
  }

  @Builder
  FunctionButton(imageButton: ImageButtonOption) {
    Button(imageButton.buttonText)
      .fontSize(CommonConstant.TextSizeNormal)
      .fontWeight(FontWeight.Bold)
      .backgroundColor($r('app.color.glass_background'))
      .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
      .border({ width: CommonConstant.BorderSizeNormal, color: $r('app.color.glass_border') })
      .width(CommonConstant.FullPercent)
      .onClick(() => {
        if (imageButton.buttonOnclick) {
          imageButton.buttonOnclick();
        }
      })
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

        Row() {
          FloatButton({ isFloating: true, floatIcon: $r('sys.symbol.xmark') })
            .onClick(() => {
              this.backToFirstPage();
            })
          if (!this.hideIndicator) {
            this.Indicator()
          } else {
            Blank()
          }
          FloatButton()
            .opacity(0)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width(CommonConstant.FullPercent)
        .position({ top: 0 })
        .padding({
          top: CommonConstant.TopBarHeight,
          left: CommonConstant.PageLRPadding,
          right: CommonConstant.PageLRPadding
        })
        .opacity(this.bgOpacity)

        Column({ space: CommonConstant.NormalContainerInnerPadding }) {
          ForEach(this.buttons, (imageButton: ImageButtonOption, index: number) => {
            this.FunctionButton(imageButton);
          }, (imageButton: ImageButtonOption, index: number) => index.toString())
        }
        .padding({
          left: CommonConstant.PageLRPadding,
          right: CommonConstant.PageLRPadding
        })
        .constraintSize({ maxWidth: 400 })
        .width(CommonConstant.FullPercent)
        .position({
          bottom: CommonConstant.BottomBarHeight
        })
        .opacity(this.bgOpacity)
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
        this.hideIndicator = param.hideIndicator !== undefined ? param.hideIndicator as boolean : false;
        this.buttons = (param.imageButtons as ImageButtonOption[]) ?? [];
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
