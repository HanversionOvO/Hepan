import { AnPNotification, CommonConstant, DateUtil, SystemNotification } from 'base_common';
import { NoticePageVM } from '../viewmodels/NoticePageVM';

@ComponentV2
export struct NoticeCard {
  @Param @Require noticeCard: SystemNotification | AnPNotification;
  @Param @Require vm: NoticePageVM;

  @Computed
  get systemMsg(): SystemNotification | null {
    if (this.vm.messageNotifyCard?.type === 'system') {
      return this.noticeCard as SystemNotification;
    }
    return null;
  }

  @Computed
  get anpMsg(): AnPNotification | null {
    if (this.vm.messageNotifyCard?.type !== 'system') {
      return this.noticeCard as AnPNotification;
    }
    return null;
  }

  @Computed
  get systemAuthor(): string {
    if (!this.systemMsg) {
      return '';
    }
    const author = this.systemMsg.author.trim();
    return author.length > 0 ? author : '系统';
  }

  private formatReplyContent(content: string): string {
    if (!content) {
      return '';
    }
    const lines = content.split(/\r?\n/);
    const filteredLines = lines.filter(line => !line.trim().startsWith('>'));
    return filteredLines.join('\n').trim();
  }

  build() {
    Row({ space: CommonConstant.NormalContainerInnerPadding }) {
      // 1. 左侧头像区
      if (this.systemMsg) {
        // 系统通知图标
        Stack() {
          Circle()
            .width(CommonConstant.IconSizeLarge)
            .height(CommonConstant.IconSizeLarge)
            .fill($r('app.color.start_window_background'))
          SymbolGlyph($r('sys.symbol.bell_fill'))
            .fontSize(CommonConstant.IconSizeNormal)
            .fontColor([this.vm.messageNotifyCard?.iconColor])
        }
        .alignSelf(ItemAlign.Start)
      } else if (this.anpMsg) {
        Image(this.anpMsg.icon)
          .width(CommonConstant.IconSizeLarge)
          .height(CommonConstant.IconSizeLarge)
          .borderRadius(CommonConstant.RadiusRound)
          .alignSelf(ItemAlign.Start)
      }

      // 2. 右侧内容区
      Column({ space: CommonConstant.NormalContainerInnerPadding }) {
        // 头部：昵称/标题 + 时间
        Row() {
          if (this.systemMsg) {
            Text(this.systemAuthor)
              .fontSize(CommonConstant.TextSizeNormal)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
              .layoutWeight(1)
          } else if (this.anpMsg) {
            Text(this.anpMsg.reply_nick_name)
              .fontSize(CommonConstant.TextSizeNormal)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
              .layoutWeight(1)
          }

          Text(DateUtil.getRelativeTime(this.systemMsg ? this.systemMsg.dateline : Number(this.anpMsg?.replied_date ?? 0)))
            .fontSize(CommonConstant.TextSizeSmall)
            .fontColor($r('sys.color.font_tertiary'))
        }
        .width(CommonConstant.FullPercent)

        if (this.systemMsg) {
          Text(this.systemMsg.message)
            .fontSize(CommonConstant.TextSizeNormal)
            .fontColor($r('sys.color.font_primary'))
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        } else if (this.anpMsg) {
          Text(this.formatReplyContent(this.anpMsg.reply_content))
            .fontSize(CommonConstant.TextSizeNormal)
            .fontColor($r('sys.color.font_primary'))
            .maxLines(4)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }

        if (this.anpMsg && this.anpMsg.topic_subject) {
          Row() {
            Text(this.anpMsg.topic_subject)
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
