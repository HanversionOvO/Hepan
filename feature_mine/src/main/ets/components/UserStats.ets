import { CommonConstant } from 'base_common';
export interface UserStatsModel {
  label: ResourceStr,
  count: number,
  onClick?: () => void,
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