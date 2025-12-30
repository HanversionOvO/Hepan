import { BaseVM, CommonConstant } from 'base_common';
export interface CustomTabItem {
  label: ResourceStr;
  icon: Resource;
}

@ComponentV2
export struct CustomTabBar {
  @Param @Require tabItems: CustomTabItem[];
  @Param @Require vm: BaseVM;
  @Param currentIndex: number = 0;
  @Param tabButtonWidth: Length = 84;
  @Param tabButtonHeight: Length = 34;
  @Param alignMode: FlexAlign = FlexAlign.Center;
  @Param indicatorColor: ResourceColor = CommonConstant.ThemeColor;
  @Param activeTextColor: ResourceColor = $r("sys.color.font_on_primary");
  @Param inactiveTextColor: ResourceColor = $r("sys.color.font_secondary");
  @Param barBackgroundColor: ResourceColor = Color.Transparent; // 整体背景
  @Param barBorderRadius: Length = CommonConstant.RadiusRound;
  @Param isGlassStyle: boolean = false;
  @Param isMax: boolean = true;
  @Event changeTab: (index: number) => void;
  @Local private tabPositions: number[] = [];

  @Computed
  get indicatorOffset(): number {
    return this.tabPositions[this.currentIndex] || 0;
  }

  private handleTabClick(index: number) {
    this.changeTab(index);
  }

  @Builder
  TabButton(index: number, item: CustomTabItem) {
    Button({ type: ButtonType.Normal }) {
      Row({ space: CommonConstant.SmallContainerInnerPadding }) {
        SymbolGlyph(item.icon)
          .fontSize(CommonConstant.TextSizeNormal)
          .fontWeight(FontWeight.Bold)
          .fontColor([this.currentIndex === index ? this.activeTextColor : this.inactiveTextColor])
          .animation({ duration: CommonConstant.AnimationDurationNormal })

        Text(item.label)
          .fontSize(CommonConstant.TextSizeSmall)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.currentIndex === index ? this.activeTextColor : this.inactiveTextColor)
          .animation({ duration: CommonConstant.AnimationDurationNormal })
      }
    }
    .borderRadius(CommonConstant.RadiusRound)
    .width(this.tabButtonWidth)
    .height(this.tabButtonHeight)
    .backgroundColor(Color.Transparent)
    .onClick(() => {
      this.handleTabClick(index);
    })
    .onAreaChange((_oldVal, newVal) => {
      const newX = newVal.position.x as number;
      if (this.tabPositions[index] !== newX) {
        this.tabPositions[index] = newX;
      }
    })
  }

  build() {
    Scroll() {
      Stack({ alignContent: Alignment.TopStart }) {
        // 1. 背景指示器
        if (this.tabPositions.length > 0) {
          Row()
            .width(this.tabButtonWidth)
            .height(this.tabButtonHeight)
            .backgroundColor(this.indicatorColor)
            .borderRadius(CommonConstant.RadiusRound)
            .translate({ x: this.indicatorOffset })
            .animation({ curve: CommonConstant.AnimationCurveSpring, duration: CommonConstant.AnimationDurationNormal })
        }

        // 2. Tab 按钮层
        Row({ space: CommonConstant.NormalContainerInnerPadding }) {
          ForEach(this.tabItems, (item: CustomTabItem, index: number) => {
            this.TabButton(index, item)
          })
        }
        .constraintSize(this.isMax ? { minWidth: CommonConstant.FullPercent } : undefined)
        .justifyContent(this.alignMode)
      }
      .constraintSize(this.isMax ? { minWidth: CommonConstant.FullPercent } : undefined)
    }
    .padding(this.isGlassStyle ? CommonConstant.NormalContainerTBPadding : 0)
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .align(Alignment.Start)
    .backgroundColor(this.barBackgroundColor)
    .borderRadius(this.barBorderRadius)
    .backgroundBlurStyle(this.isGlassStyle ? BlurStyle.BACKGROUND_THICK : BlurStyle.NONE)
    .border(this.isGlassStyle ? { width: CommonConstant.BorderSizeNormal, color: $r('app.color.glass_border') } : {})
    .animation({ duration: CommonConstant.AnimationDurationNormal })
  }
}