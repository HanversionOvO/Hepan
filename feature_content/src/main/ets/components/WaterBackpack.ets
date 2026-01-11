import { CommonConstant, UiState, WaterBackpackItem } from 'base_common';
import { StateLayout } from 'base_ui';
import { WaterVM } from '../viewmodels/WaterVM';

@ComponentV2
export struct WaterBackPack {
  @Param @Require vm: WaterVM;
  @Local backpackItems: WaterBackpackItem[] = [];
  @Local isLoadingShop: UiState = UiState.LOADING;

  async aboutToAppear() {
    this.backpackItems = await this.vm.getBackpack();

    if (this.backpackItems.length > 0) {
      this.isLoadingShop = UiState.SUCCESS;
    } else {
      this.isLoadingShop = UiState.EMPTY;
    }
  }

  @Builder
  backpackItemCard(item: WaterBackpackItem) {
    Column({ space: CommonConstant.NormalContainerInnerPadding }) {
      Stack() {
        Column() {
          Image(item.backpack_icon)
            .width(CommonConstant.IconSizeLarge)
            .height(CommonConstant.IconSizeLarge)
        }
        .padding(CommonConstant.NormalContainerTBPadding)

        Text(`x${item.backpack_nums}`)
          .padding(CommonConstant.SmallContainerInnerPadding)
          .position({ right: 0, top: 0 })
          .fontSize(CommonConstant.TextSizeTiny)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor($r('app.color.water_color'))
          .borderRadius({
            topLeft: 0,
            topRight: CommonConstant.RadiusNormal,
            bottomLeft: CommonConstant.RadiusNormal,
            bottomRight: 0
          })
      }
      .backgroundColor($r('app.color.second_window_background'))
      .width(CommonConstant.FullPercent)
      .borderRadius(CommonConstant.RadiusNormal)

      Column({ space: CommonConstant.SmallContainerInnerPadding }) {
        Text(item.backpack_name)
          .fontSize(CommonConstant.TextSizeNormal)
          .fontWeight(FontWeight.Medium)
      }
      .width(CommonConstant.FullPercent)
    }
    .borderRadius(CommonConstant.RadiusNormal)
    .backgroundColor($r('app.color.start_window_background'))
    .padding(CommonConstant.NormalContainerInnerPadding)
    .width(CommonConstant.FullPercent)
  }

  build() {
    StateLayout({
      uiState: this.isLoadingShop
    }) {
      Refresh({ refreshing: $$this.vm.isRefreshBackpack }) {
        Grid() {
          ForEach(this.backpackItems, (item: WaterBackpackItem, index: number) => {
            GridItem() {
              this.backpackItemCard(item)
            }
            .width(CommonConstant.FullPercent)
          }, (mission: WaterBackpackItem, index: number) => index.toString())
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