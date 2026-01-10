import { CommonConstant } from 'base_common';
import { FloatButton } from 'base_ui';
import { WaterVM } from '../viewmodels/WaterVM';
import { LengthMetrics } from '@kit.ArkUI';

@ComponentV2
export struct WaterView {
  @Param @Require vm: WaterVM;

  @Computed
  get waterCardWidth(): Length {
    return this.vm.isTabletView ? 340 : CommonConstant.FullPercent;
  }

  @Computed
  get waterCardHeight(): Length {
    return this.vm.isTabletView ? CommonConstant.FullPercent : "auto";
  }

  async aboutToAppear() {
    await this.vm.loadData();
  }

  @Builder
  WaterCard() {
    Stack({ alignContent: this.vm.isTabletView ? Alignment.Top : Alignment.Center }) {
      Column({ space: CommonConstant.SmallContainerInnerPadding }) {
        Text("当前水滴")
          .fontSize(CommonConstant.TextSizeSmall)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_secondary'))

        Text(this.vm.water.water_nums.toString())
          .fontSize(CommonConstant.TextSizeUltraLarge)
          .fontWeight(FontWeight.Bolder)
      }
      .width(CommonConstant.FullPercent)
      .alignItems(HorizontalAlign.Start)

      SymbolGlyph($r('sys.symbol.drop_fill'))
        .fontSize(CommonConstant.IconSizeUltraLarge)
        .fontColor([$r('sys.color.font_on_primary')])
        .opacity(0.15)
        .rotate({ angle: 15 })
        .position({
          right: -CommonConstant.NormalContainerInnerPadding,
          bottom: -CommonConstant.NormalContainerInnerPadding
        })
        .hitTestBehavior(HitTestMode.None)
    }
    .clip(true)
    .width(this.waterCardWidth)
    .padding(CommonConstant.NormalContainerInnerPadding)
    .backgroundColor($r('app.color.glass_background'))
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THICK)
    .borderRadius(CommonConstant.RadiusLarge)
    .height(this.waterCardHeight)
    .border({ width: CommonConstant.BorderSizeLarge, color: $r('app.color.glass_border') })
    .margin({
      top: this.vm.isTabletView ?
        this.vm.window.windowTopPadding + CommonConstant.TopBarHeight + CommonConstant.NormalContainerInnerPadding : 0
    })
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row({ space: CommonConstant.NormalContainerInnerPadding }) {
        FloatButton({ isFloating: true })
        Text($r('app.string.WaterPage_water'))
          .fontSize(CommonConstant.TextSizeUltraLarge)
          .fontColor($r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Bold)
      }
      .alignItems(VerticalAlign.Center)
      .height(CommonConstant.TopBarHeight + this.vm.window.windowTopPadding)
      .padding({
        left: CommonConstant.PageLRPadding,
        top: this.vm.window.windowTopPadding
      })

      Flex({
        direction: this.vm.isTabletView ? FlexDirection.Row : FlexDirection.Column, space: {
          main: LengthMetrics.vp(CommonConstant.NormalContainerInnerPadding)
        }
      }) {
        if (!this.vm.isTabletView) {
          Column()
            .height(CommonConstant.TopBarHeight + this.vm.window.windowTopPadding)
        }

        this.WaterCard()

        Column()
          .layoutWeight(1)
      }
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
      .padding({
        left: CommonConstant.PageLRPadding,
        right: CommonConstant.PageLRPadding
      })
    }
    .backgroundColor($r('app.color.water_color'))
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
  }
}