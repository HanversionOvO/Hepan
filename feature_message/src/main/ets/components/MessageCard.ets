import { CommonConstant, DateUtil, RecentMessage, ToastUtil, UserAvatarUtil } from 'base_common';
import { MessagePageVM } from '../viewmodels/MessagePageVM';

@ComponentV2
export struct MessageCard {
  @Param @Require vm: MessagePageVM;
  @Param @Require message: RecentMessage;
  @Local offsetX: number = 0;
  @Local startOffset: number = 0;
  @Local cardHeight: number = 0;

  private getActionWidth(): number {
    return CommonConstant.IconSizeLarge + CommonConstant.NormalContainerInnerPadding * 2;
  }

  private clampOffset(value: number): number {
    const minOffset = -this.getActionWidth();
    if (value < minOffset) {
      return minOffset;
    }
    if (value > 0) {
      return 0;
    }
    return value;
  }

  private toNumber(value: Length): number {
    if (typeof value === 'number') {
      return value;
    }
    if (typeof value === 'string') {
      const parsed = Number.parseFloat(value);
      return Number.isNaN(parsed) ? 0 : parsed;
    }
    return 0;
  }

  private updateCardHeight(height: Length): void {
    const nextHeight = this.toNumber(height);
    if (this.cardHeight !== nextHeight) {
      this.cardHeight = nextHeight;
    }
  }

  private settleOffset(): void {
    const threshold = -this.getActionWidth() / 2;
    const shouldOpen = this.offsetX < threshold;
    const target = shouldOpen ? -this.getActionWidth() : 0;
    animateTo({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring }, () => {
      this.offsetX = target;
    });
  }

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
    .padding({
      left: CommonConstant.NormalContainerInnerPadding,
      right: CommonConstant.NormalContainerInnerPadding
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Row() {
        this.DeleteAction()
      }
      .width(CommonConstant.FullPercent)
      .height(this.cardHeight > 0 ? this.cardHeight : undefined)
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center)

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
      .translate({ x: this.offsetX, y: 0 })
      .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.85 })
      .onAreaChange((_oldArea, newArea) => {
        this.updateCardHeight(newArea.height);
      })
      .gesture(
        PanGesture({ direction: PanDirection.Horizontal })
          .onActionStart(() => {
            this.startOffset = this.offsetX;
          })
          .onActionUpdate((event: GestureEvent) => {
            this.offsetX = this.clampOffset(this.startOffset + event.offsetX);
          })
          .onActionEnd(() => {
            this.settleOffset();
          })
          .onActionCancel(() => {
            this.settleOffset();
          })
      )
    }
    .width(CommonConstant.FullPercent)
  }
}
