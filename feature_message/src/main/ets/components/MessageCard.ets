import { CommonConstant, DateUtil, RecentMessage, ToastUtil, UserAvatarUtil } from 'base_common';
import { MessagePageVM } from '../viewmodels/MessagePageVM';

@ComponentV2
export struct MessageCard {
  @Param @Require vm: MessagePageVM;
  @Param @Require message: RecentMessage;
  @Param onCardClick: () => void = () => {
  };

  private confirmDelete(): void {
    const userName = this.message.toUserName?.trim();
    const messageText = userName
      ? `是否清空与 ${userName} 的聊天消息`
      : '是否清空该用户的聊天消息';
    ToastUtil.showWarn(messageText, true, undefined, () => {
      this.vm.deleteConversation(this.message);
    });
  }

  @Builder
  DeleteAction() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.trash'))
          .fontColor([$r('sys.color.font_on_primary')])
          .fontSize(CommonConstant.TextSizeLarge)
      }
      .type(ButtonType.Circle)
      .backgroundColor(CommonConstant.ErrorColor)
      .width(CommonConstant.IconSizeLarge)
      .height(CommonConstant.IconSizeLarge)
      .onClick(() => {
        this.confirmDelete();
      })
    }
    .padding(CommonConstant.NormalContainerInnerPadding)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }

  build() {
    ListItem() {
      Row({ space: CommonConstant.NormalContainerInnerPadding }) {
        Badge({
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
      .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.85 })
      .onClick(() => {
        this.onCardClick();
      })
    }
    .swipeAction({
      end: () => {
        this.DeleteAction();
      },
      edgeEffect: SwipeEdgeEffect.Spring
    })
  }
}