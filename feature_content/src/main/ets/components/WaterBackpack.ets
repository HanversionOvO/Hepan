import { CommonConstant, UiState } from 'base_common';
import { StateLayout } from 'base_ui';
import { WaterVM } from '../viewmodels/WaterVM';

@ComponentV2
export struct WaterBackPack {
  @Param @Require vm: WaterVM;
  @Local isLoadingShop: UiState = UiState.LOADING;

  async aboutToAppear() {

  }

  // @Builder
  // ShopItemCard(item: WaterShopItem) {
  //   Column({ space: CommonConstant.NormalContainerInnerPadding }) {
  //     Row() {
  //       Image(item.shop_icon)
  //         .width(CommonConstant.IconSizeLarge)
  //         .height(CommonConstant.IconSizeLarge)
  //     }
  //     .backgroundColor($r('app.color.second_window_background'))
  //     .width(CommonConstant.FullPercent)
  //     .borderRadius(CommonConstant.RadiusNormal)
  //     .padding(CommonConstant.NormalContainerTBPadding)
  //     .alignItems(VerticalAlign.Center)
  //     .justifyContent(FlexAlign.Center)
  //
  //     Column({ space: CommonConstant.SmallContainerInnerPadding }) {
  //       Text(item.shop_name)
  //         .fontSize(CommonConstant.TextSizeNormal)
  //         .fontWeight(FontWeight.Medium)
  //
  //       Row() {
  //         if (item.can_buy) {
  //           Row({ space: CommonConstant.SmallContainerInnerPadding }) {
  //             SymbolGlyph($r('sys.symbol.drop_fill'))
  //               .fontSize(CommonConstant.TextSizeSmall)
  //               .fontColor([$r('app.color.water_color')])
  //
  //             Text(item.shop_price.toString())
  //               .fontSize(CommonConstant.TextSizeSmall)
  //               .fontColor($r('app.color.water_color'))
  //               .fontWeight(FontWeight.Bold)
  //           }
  //
  //           GlassButton({
  //             text: $r('app.string.WaterPage_shop_buy'),
  //             innerFontSize: CommonConstant.TextSizeTiny
  //           })
  //         } else {
  //           Row() {
  //             GlassButton({
  //               text: $r('app.string.WaterPage_shop_cant_buy'),
  //               innerFontSize: CommonConstant.TextSizeTiny
  //             })
  //           }
  //           .width(CommonConstant.FullPercent)
  //           .justifyContent(FlexAlign.Center)
  //         }
  //       }
  //       .width(CommonConstant.FullPercent)
  //       .justifyContent(FlexAlign.SpaceBetween)
  //     }
  //     .width(CommonConstant.FullPercent)
  //   }
  //   .borderRadius(CommonConstant.RadiusNormal)
  //   .backgroundColor($r('app.color.start_window_background'))
  //   .padding(CommonConstant.NormalContainerInnerPadding)
  //   .width(CommonConstant.FullPercent)
  // }

  build() {
    StateLayout({
      uiState: this.isLoadingShop
    }) {
      Refresh({ refreshing: $$this.vm.isRefreshBackpack }) {
        Grid() {
          // ForEach(this.shopItems, (item: WaterShopItem, index: number) => {
          //   GridItem() {
          //     this.ShopItemCard(item)
          //   }
          //   .width(CommonConstant.FullPercent)
          // }, (mission: WaterShopItem, index: number) => index.toString())
        }
        .width(CommonConstant.FullPercent)
        .layoutWeight(1)
        .columnsTemplate('1fr '.repeat(this.vm.shopColumns)
          .trim())
        .columnsGap(CommonConstant.NormalContainerInnerPadding)
        .rowsGap(CommonConstant.NormalContainerInnerPadding)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
  }
}