import { CommonConstant, VMManager } from 'base_common';
import { ApplicationCard, ApplicationCardItem } from '../components/ApplicationCard';
import { ApplicationVM } from '../viewmodels/ApplicationVM';

@ComponentV2
export struct ApplicationView {
  @Local vm: ApplicationVM = VMManager.get(ApplicationVM, () => new ApplicationVM());
  @Param topSpace: number = CommonConstant.IconSizeLarge + CommonConstant.NormalContainerInnerPadding;

  @Computed
  get initialTopSpaceHeight(): number {
    return CommonConstant.TopBarHeight + this.vm.window.windowTopPadding + this.topSpace;
  }

  async aboutToAppear() {
    await this.vm.loadData();
  }

  build() {
    Column() {
      Column()
        .height(this.initialTopSpaceHeight)

      Stack() {
        WaterFlow() {
          ForEach(this.vm.applications, (application: ApplicationCardItem, index: number) => {
            FlowItem() {
              ApplicationCard({ application })
                .id(application.id)
            }
            .width(CommonConstant.FullPercent)
          }, (application: ApplicationCardItem, index: number) => index.toString())
        }
        .width(CommonConstant.FullPercent)
        .layoutWeight(1)
        .columnsTemplate('1fr '.repeat(this.vm.columns)
          .trim())
        .columnsGap(CommonConstant.NormalContainerInnerPadding)
        .rowsGap(CommonConstant.NormalContainerInnerPadding)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
    .padding({
      left: CommonConstant.PageLRPadding,
      right: CommonConstant.PageLRPadding
    })
    .scale({
      x: this.vm.pageScale,
      y: this.vm.pageScale,
    })
  }
}