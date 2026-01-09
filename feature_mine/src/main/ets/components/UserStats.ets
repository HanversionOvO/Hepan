import { CommonConstant } from 'base_common';

@ObservedV2
export class UserStatsModel {
  @Trace label: ResourceStr = "";
  @Trace count: number = 0;
  @Trace onClick?: () => void;
}

@ComponentV2
export struct UserStats {
  @Param @Require userStatsModel: UserStatsModel;

  build() {
    Column({ space: CommonConstant.SmallContainerInnerPadding }) {
      Text(this.userStatsModel.count.toString())
        .fontSize(CommonConstant.TextSizeLarge)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_primary'))
      Text(this.userStatsModel.label)
        .fontSize(CommonConstant.TextSizeSmall)
        .fontColor($r('sys.color.font_on_primary'))
    }
    .onClick(() => {
      if (this.userStatsModel.onClick) {
        this.userStatsModel.onClick();
      }
    })
  }
}