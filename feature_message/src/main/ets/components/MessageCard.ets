import { CommonConstant, DateUtil, RecentMessage, UserAvatarUtil } from 'base_common';
import { MessagePageVM } from '../viewmodels/MessagePageVM';

@ComponentV2
export struct MessageCard {
  @Param @Require vm: MessagePageVM;
  @Param @Require message: RecentMessage;

  build() {
    Row({ space: CommonConstant.NormalContainerInnerPadding }) {
      Badge({
        // 修复：必须明确判断 '1'，因为 '0' 字符串也是真值
        count: this.message.isNew === '1' ? 1 : 0,
        style: {
          badgeColor: CommonConstant.ErrorColor,
          badgeSize: CommonConstant.TextSizeTiny,
          fontSize: CommonConstant.TextSizeUltraTiny
        }
      }) {
        Image(UserAvatarUtil.getAvatarUrl(this.message.toUserId))
          .width(CommonConstant.IconSizeLarge)
          .height(CommonConstant.IconSizeLarge)
          .borderRadius(CommonConstant.RadiusRound)
      }

      // 内容区
      Column({ space: CommonConstant.SmallContainerInnerPadding }) {
        Row() {
          Text(this.message.toUserName)
            .fontSize(CommonConstant.TextSizeNormal)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)

          Text(DateUtil.getRelativeTime(this.message.lastDateline))
            .fontSize(CommonConstant.TextSizeTiny)
            .fontColor($r('sys.color.font_tertiary'))
        }
        .width(CommonConstant.FullPercent)
        .alignItems(VerticalAlign.Center)

        Text(this.message.lastSummary)
          .fontSize(CommonConstant.TextSizeSmall)
          .fontColor($r('sys.color.font_secondary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .transition(TransitionEffect.OPACITY.animation({ duration: CommonConstant.AnimationDurationNormal }))
    }
    .width(CommonConstant.FullPercent)
    .padding(CommonConstant.NormalContainerInnerPadding)
    .backgroundColor($r('app.color.second_window_background'))
    .borderRadius(CommonConstant.RadiusLarge)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}