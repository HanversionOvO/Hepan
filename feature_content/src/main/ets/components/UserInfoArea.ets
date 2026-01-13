import { DateUtil } from '@pura/harmony-utils';
import { CommonConstant, RouterMap, RouterUtil, UserAvatarUtil } from 'base_common';
import { GlassButton } from 'base_ui';
import { TieContentPageVM } from '../viewmodels/TieContentPageVM';

@ComponentV2
export struct UserInfoArea {
  @Param @Require vm: TieContentPageVM;

  private getAuthorId(): number {
    return this.vm.tieThread.author_id || this.vm.tieSummary.author_id;
  }

  private getAuthorName(): string {
    return this.vm.tieThread.author || this.vm.tieSummary.author || '';
  }

  private getDateline(): number {
    return this.vm.tieThread.dateline || this.vm.tieSummary.dateline;
  }

  private hasAuthor(): boolean {
    return this.getAuthorId() !== 0 || this.getAuthorName().length > 0;
  }

  private getAuthorAvatar(): ResourceStr {
    return this.getAuthorId() === 0 ? $r('app.media.anonymous') : UserAvatarUtil.getAvatarUrl(this.getAuthorId());
  }

  private goToUserProfile(): void {
    const authorId = this.getAuthorId();
    if (authorId) {
      RouterUtil.pushPathByName(RouterMap.USER_PROFILE, authorId);
    }
  }

  build() {
    Column() {
      if (this.hasAuthor()) {
        Row() {
          Row({ space: CommonConstant.NormalContainerInnerPadding }) {
            Image(this.getAuthorAvatar())
              .width(CommonConstant.IconSizeLarge)
              .height(CommonConstant.IconSizeLarge)
              .borderRadius(CommonConstant.RadiusRound)
            Column({ space: CommonConstant.SmallContainerInnerPadding }) {
              Text(this.getAuthorName())
                .fontSize(CommonConstant.TextSizeNormal)
                .fontColor($r('sys.color.font_secondary'))
                .fontWeight(FontWeight.Medium)

              Text(DateUtil.getFormatDateStr(this.getDateline()))
                .fontSize(CommonConstant.TextSizeTiny)
                .fontColor($r('sys.color.font_tertiary'))
            }
            .alignItems(HorizontalAlign.Start)
          }
          .onClick(() => {
            this.goToUserProfile();
          })

          GlassButton({
            text: $r('app.string.TieContentPage_subscribe'),
            innerFontSize: CommonConstant.TextSizeSmall
          })
        }
        .width(CommonConstant.FullPercent)
        .justifyContent(FlexAlign.SpaceBetween)
      }
    }
    .width(CommonConstant.FullPercent)
  }
}
