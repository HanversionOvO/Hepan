import { CommonConstant, UserAvatarUtil } from 'base_common';
import { ChatPageVM } from '../viewmodels/ChatPageVM';

@ComponentV2
export struct ChatNavBar {
  @Param @Require vm: ChatPageVM;

  build() {
    Row({ space: CommonConstant.NormalContainerInnerPadding }) {
      if (this.vm.recentMessage) {
        Stack({ alignContent: Alignment.BottomEnd }) {
          Image(UserAvatarUtil.getAvatarUrl(this.vm.recentMessage.toUserId))
            .width(CommonConstant.IconSizeLarge)
            .height(CommonConstant.IconSizeLarge)
            .borderRadius(CommonConstant.RadiusRound)

          if (this.vm.isUserOnline) {
            Circle()
              .width(CommonConstant.TextSizeSmall)
              .height(CommonConstant.TextSizeSmall)
              .fill(CommonConstant.SuccessColor)
              .borderRadius(CommonConstant.RadiusRound)
              .border({ width: CommonConstant.BorderSizeLarge, color: $r('sys.color.font_on_primary') })
          }
        }

        Column({ space: CommonConstant.SmallContainerInnerPadding }) {
          Text(this.vm.recentMessage.toUserName)
            .fontSize(CommonConstant.TextSizeNormal)
            .fontWeight(FontWeight.Bold)

          Text(this.vm.isUserOnline ? $r('app.string.ChatPage_user_online') : $r('app.string.ChatPage_user_offline'))
            .fontSize(CommonConstant.TextSizeSmall)
            .fontColor($r('sys.color.font_tertiary'))
        }
        .alignItems(HorizontalAlign.Start)
      }
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.TopBarHeight + this.vm.window.windowTopPadding)
    .backgroundColor($r('app.color.second_window_background'))
    .justifyContent(FlexAlign.Start)
    .zIndex(1)
    .padding({
      top: this.vm.window.windowTopPadding,
      left: CommonConstant.PageLRPadding + CommonConstant.IconSizeLarge + CommonConstant.NormalContainerInnerPadding,
      right: CommonConstant.PageLRPadding
    })
    .transition(TransitionEffect.move(TransitionEdge.TOP).combine(TransitionEffect.opacity(0)))
    .expandSafeArea([SafeAreaType.KEYBOARD])
  }
}