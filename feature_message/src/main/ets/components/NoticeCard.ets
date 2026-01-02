import { AnPNotification, CommonConstant, DateUtil } from 'base_common';
import { NoticePageVM } from '../viewmodels/NoticePageVM';

@ComponentV2
export struct NoticeCard {
  @Param @Require messageCard: AnPNotification;
  @Param @Require vm: NoticePageVM;

  build() {
    Row({ space: CommonConstant.NormalContainerInnerPadding }) {
      // 1. 左侧头像区
      if (this.vm.messageNotifyCard?.type === "system") {
        // 系统通知图标
        Stack() {
          Circle()
            .width(CommonConstant.IconSizeLarge)
            .height(CommonConstant.IconSizeLarge)
            .fill($r('app.color.start_window_background'))
          SymbolGlyph($r('sys.symbol.bell_fill'))
            .fontSize(CommonConstant.IconSizeNormal)
            .fontColor([this.vm.messageNotifyCard.iconColor])
        }
      } else {
        Image(this.messageCard.icon)
          .width(CommonConstant.IconSizeLarge)
          .height(CommonConstant.IconSizeLarge)
          .borderRadius(CommonConstant.RadiusRound)
          .alignSelf(ItemAlign.Start)
      }

      // 2. 右侧内容区
      Column({ space: CommonConstant.NormalContainerInnerPadding }) {
        // 头部：昵称/标题 + 时间
        Row() {
          Text(this.messageCard.reply_nick_name)
            .fontSize(CommonConstant.TextSizeNormal)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
            .layoutWeight(1)

          Text(DateUtil.getRelativeTime(Number(this.messageCard.replied_date)))
            .fontSize(CommonConstant.TextSizeSmall)
            .fontColor($r('sys.color.font_tertiary'))
        }
        .width(CommonConstant.FullPercent)

        Text(this.messageCard.reply_content)
          .fontSize(CommonConstant.TextSizeNormal)
          .fontColor($r('sys.color.font_primary'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (this.messageCard.topic_subject) {
          Row() {
            Text(this.messageCard.topic_subject)
              .fontSize(CommonConstant.TextSizeSmall)
              .fontColor($r('sys.color.font_secondary'))
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width(CommonConstant.FullPercent)
          .padding({
            top: CommonConstant.SmallContainerTBPadding,
            bottom: CommonConstant.SmallContainerTBPadding,
            left: CommonConstant.SmallContainerLRPadding,
            right: CommonConstant.SmallContainerLRPadding
          })
          .backgroundColor($r('app.color.start_window_background'))
          .borderRadius(CommonConstant.RadiusTiny)
          .border({
            width: { left: CommonConstant.BorderSizeLarge },
            color: CommonConstant.ThemeColor
          }) // 左侧装饰线
          .margin({ top: CommonConstant.BorderSizeLarge })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width(CommonConstant.FullPercent)
    .padding(CommonConstant.NormalContainerInnerPadding)
    .backgroundColor($r('app.color.second_window_background'))
    .borderRadius(CommonConstant.RadiusLarge)
  }
}