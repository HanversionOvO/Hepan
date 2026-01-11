import { CommonConstant, WaterRecord } from 'base_common';
import { CustomTabBar, FloatButton } from 'base_ui';
import { WaterVM } from '../viewmodels/WaterVM';
import { LengthMetrics } from '@kit.ArkUI';
import { ResUtil } from '@pura/harmony-utils';
import { WaterEarnWater } from '../components/WaterEarnWater';
import { WaterShop } from '../components/WaterShop';

@ComponentV2
export struct WaterView {
  @Param @Require vm: WaterVM;

  @Computed
  get waterCardWidth(): Length {
    return this.vm.isTabletView ? 340 : CommonConstant.FullPercent;
  }

  @Computed
  get waterCardHeight(): Length {
    if (this.vm.isTabletView) {
      const topOffset =
        this.vm.window.windowTopPadding + CommonConstant.TopBarHeight + CommonConstant.NormalContainerInnerPadding;
      return `calc(${CommonConstant.FullPercent} - ${topOffset}vp)`;
    }
    return "auto";
  }

  async aboutToAppear() {
    await this.vm.loadData();
  }

  @Builder
  WaterDetailSheet() {
    List({ space: CommonConstant.NormalContainerInnerPadding }) {
      ForEach(this.vm.water.records, (record: WaterRecord, index: number) => {
        ListItem() {
          this.WaterDetailCard(record)
        }
      }, (record: WaterRecord, index: number) => index.toString())

      if (!this.vm.isTabletView) {
        ListItem()
          .height(this.vm.window.windowBottomPadding)
      }
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .padding({
      left: this.vm.isTabletView ? 0 : CommonConstant.NormalContainerLRPadding,
      right: this.vm.isTabletView ? 0 : CommonConstant.NormalContainerLRPadding,
    })
    .onReachEnd(async () => {
      await this.vm.loadMore();
    })
  }

  @Builder
  WaterDetailCard(record: WaterRecord) {
    Row({ space: CommonConstant.NormalContainerInnerPadding }) {
      SymbolGlyph(record.modify_state ? $r('sys.symbol.minus_circle') : $r('sys.symbol.plus_circle'))
        .fontColor(record.modify_state ? [CommonConstant.ErrorColor] : [CommonConstant.SuccessColor])
        .fontSize(CommonConstant.IconSizeLarge)
        .fontWeight(FontWeight.Bold)

      Column({ space: CommonConstant.SmallContainerInnerPadding }) {
        Text(record.modify_desc)
          .fontSize(CommonConstant.TextSizeSmall)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.MARQUEE })
          .fontColor($r('sys.color.font_on_secondary'))

        Text(`${ResUtil.getStringSync($r('app.string.WaterPage_water'))} ${record.modify_water.toString()}`)
          .fontSize(CommonConstant.TextSizeLarge)
          .fontColor($r('sys.color.font_on_primary'))

        Text(record.modyfy_info)
          .fontSize(CommonConstant.TextSizeSmall)
          .fontColor($r('sys.color.font_on_secondary'))

        Text(record.modify_time)
          .textAlign(TextAlign.End)
          .width(CommonConstant.FullPercent)
          .fontSize(CommonConstant.TextSizeTiny)
          .fontColor($r('sys.color.font_on_tertiary'))
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .alignItems(VerticalAlign.Center)
    .borderRadius(CommonConstant.RadiusNormal)
    .padding(CommonConstant.NormalContainerInnerPadding)
    .layoutWeight(1)
    .backgroundColor($r('app.color.glass_background'))
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
  }

  @Builder
  WaterCard() {
    Stack({ alignContent: this.vm.isTabletView ? Alignment.Top : Alignment.Center }) {
      Column({ space: CommonConstant.NormalContainerInnerPadding }) {
        Row() {
          Column({ space: CommonConstant.SmallContainerInnerPadding }) {
            Text($r('app.string.WaterPage_current_water'))
              .fontSize(CommonConstant.TextSizeSmall)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_on_secondary'))

            Text(this.vm.water.water_nums.toString())
              .fontSize(CommonConstant.TextSizeUltraLarge)
              .fontWeight(FontWeight.Bolder)
              .fontColor($r('sys.color.font_on_primary'))
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          if (!this.vm.isTabletView) {
            Button() {
              Row({ space: CommonConstant.SmallContainerInnerPadding }) {
                SymbolGlyph($r('sys.symbol.list_number'))
                  .fontSize(CommonConstant.TextSizeSmall)
                  .fontColor([$r('sys.color.font_on_secondary')])

                Text($r('app.string.WaterPage_water_detail'))
                  .fontSize(CommonConstant.TextSizeSmall)
                  .fontColor($r('sys.color.font_on_secondary'))
              }
            }
            .padding({
              left: CommonConstant.SmallContainerLRPadding,
              right: CommonConstant.SmallContainerLRPadding,
              top: CommonConstant.SmallContainerTBPadding,
              bottom: CommonConstant.SmallContainerTBPadding
            })
            .borderRadius(CommonConstant.RadiusSmall)
            .backgroundColor($r('app.color.glass_background'))
            .border({ width: CommonConstant.BorderSizeNormal, color: $r('app.color.glass_border') })
            .onClick(() => {
              this.vm.isShowWaterDetailSheet = true;
            })
            .bindSheet($$this.vm.isShowWaterDetailSheet, this.WaterDetailSheet(), {
              showClose: true,
              detents: [SheetSize.FIT_CONTENT],
              enableOutsideInteractive: false,
              preferType: this.vm.isTabletView ? SheetType.CENTER : SheetType.BOTTOM,
              backgroundColor: $r('app.color.glass_background'),
              blurStyle: BlurStyle.BACKGROUND_ULTRA_THICK,
              title: {
                title: $r('app.string.WaterPage_water_detail')
              }
            })
          }
        }
        .width(CommonConstant.FullPercent)
        .justifyContent(FlexAlign.SpaceBetween)

        if (this.vm.isTabletView) {
          Divider()
            .strokeWidth(CommonConstant.BorderSizeNormal)
            .color($r('sys.color.font_on_tertiary'))

          this.WaterDetailSheet()
        }
      }
      .layoutWeight(1)

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

  @Builder
  WaterContent() {
    Column() {
      Tabs({ index: this.vm.currentIndex }) {
        TabContent() {
          WaterEarnWater({ vm: this.vm })
        }

        TabContent() {
          WaterShop({ vm: this.vm })
        }

        TabContent() {
          Text("3")
        }

        TabContent() {
          Text("4")
        }
      }
      .barHeight(0)
      .scrollable(false)
    }
    .padding(CommonConstant.NormalContainerInnerPadding)
    .backgroundColor($r('app.color.glass_background'))
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THICK)
    .borderRadius(CommonConstant.RadiusLarge)
    .width(CommonConstant.FullPercent)
    .border({ width: CommonConstant.BorderSizeLarge, color: $r('app.color.glass_border') })
    .layoutWeight(1)
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

        Column({ space: CommonConstant.NormalContainerInnerPadding }) {
          CustomTabBar({
            tabItems: this.vm.tabItems,
            vm: this.vm,
            isGlassStyle: true,
            currentIndex: this.vm.currentIndex,
            isMax: this.vm.isTabletView ? true : false,
            alignMode: this.vm.isTabletView ? FlexAlign.Start : FlexAlign.Center,
            changeTab: (index: number) => {
              this.vm.changeTab(index)
            }
          })

          this.WaterContent()
        }
        .margin({
          top: this.vm.isTabletView ? this.vm.window.windowTopPadding : 0
        })
        .padding({
          bottom: this.vm.isTabletView ? 0 : this.vm.window.windowBottomPadding
        })
        .layoutWeight(1)
      }
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
      .padding({
        left: CommonConstant.PageLRPadding,
        right: CommonConstant.PageLRPadding,
        bottom: this.vm.isTabletView ? this.vm.window.windowBottomPadding : 0
      })
    }
    .backgroundColor($r('app.color.water_color'))
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
  }
}