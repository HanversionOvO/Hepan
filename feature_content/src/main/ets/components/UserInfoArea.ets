import { DateUtil } from '@pura/harmony-utils';
import { CommonConstant, UserAvatarUtil } from 'base_common';
import { GlassButton } from 'base_ui';
import { TieContentPageVM } from '../viewmodels/TieContentPageVM';

@ComponentV2
export struct UserInfoArea {
  @Param @Require vm: TieContentPageVM;

  build() {
    if (this.vm.tieSummary) {
      Row() {
        Row({ space: CommonConstant.NormalContainerInnerPadding }) {
          Image(UserAvatarUtil.getAvatarUrl(this.vm.tieSummary.author_id))
            .width(CommonConstant.IconSizeLarge)
            .height(CommonConstant.IconSizeLarge)
            .borderRadius(CommonConstant.RadiusRound)
          Column({ space: CommonConstant.SmallContainerInnerPadding }) {
            Text(this.vm.tieSummary.author)
              .fontSize(CommonConstant.TextSizeNormal)
              .fontColor($r('sys.color.font_secondary'))
              .fontWeight(FontWeight.Medium)

            Text(DateUtil.getFormatDateStr(this.vm.tieSummary.dateline))
              .fontSize(CommonConstant.TextSizeTiny)
              .fontColor($r('sys.color.font_tertiary'))
          }
          .alignItems(HorizontalAlign.Start)
        }

        GlassButton({
          text: $r('app.string.TieContentPage_subscribe')
        })
      }
      .width(CommonConstant.FullPercent)
      .justifyContent(FlexAlign.SpaceBetween)
    }
  }
}