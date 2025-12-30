import { CommonConstant, UserAvatarUtil } from 'base_common';
import { MinePageVM } from '../viewmodels/MinePageVM';

@ComponentV2
export struct StickyNavBar {
  @Param @Require vm: MinePageVM;

  build() {
    Stack() {
      // 1. 背景层
      Column()
        .width(CommonConstant.FullPercent)
        .height(CommonConstant.FullPercent)
        .backgroundColor($r('app.color.start_window_background'))

      if (this.vm.user?.user_summary) {
        Row({ space: CommonConstant.SmallContainerInnerPadding }) {
          Image(UserAvatarUtil.getAvatarUrl(this.vm.user?.user_summary?.uid))
            .width(CommonConstant.IconSizeNormal)
            .height(CommonConstant.IconSizeNormal)
            .borderRadius(CommonConstant.RadiusRound)

          Text(this.vm.user.user_summary.username)
            .fontSize(CommonConstant.TextSizeNormal)
            .fontWeight(FontWeight.Bold)
        }
        .width(CommonConstant.FullPercent)
        .height(CommonConstant.FullPercent)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .padding({ top: this.vm.window.windowTopPadding })
      }
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.TopBarHeight + this.vm.window.windowTopPadding)
  }
}