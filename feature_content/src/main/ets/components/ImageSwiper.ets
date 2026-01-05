import { CommonConstant, SummaryAttachments } from 'base_common';
import { TieContentPageVM } from '../viewmodels/TieContentPageVM';

const BASE_URL = 'https://bbs.uestc.edu.cn'

@ComponentV2
export struct ImageSwiper {
  @Param @Require vm: TieContentPageVM;
  @Param @Require swiperHeight: number;

  build() {
    Stack() {
      if (this.vm.tieSummary?.summary_attachments) {
        Swiper() {
          ForEach(this.vm.tieSummary.summary_attachments, (attachment: SummaryAttachments) => {
            if (attachment.is_image) {
              Image(BASE_URL + attachment.thumbnail_url)
                .objectFit(ImageFit.Cover)
                .height(CommonConstant.FullPercent)
                .width(CommonConstant.FullPercent)
            }
          })
        }
        .indicator(false)
        .onChange((index: number) => {
          this.vm.currentImageIndex = index;
        })
      }

      Row() {
        Text(`${this.vm.currentImageIndex + 1} / ${this.vm.tieSummary?.summary_attachments?.length}`)
          .fontSize(CommonConstant.TextSizeTiny)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_on_primary'))
      }
      .borderRadius(CommonConstant.RadiusRound)
      .backgroundColor(Color.Transparent)
      .backgroundBlurStyle(BlurStyle.BACKGROUND_ULTRA_THICK)
      .padding({
        left: CommonConstant.SmallContainerLRPadding,
        right: CommonConstant.SmallContainerLRPadding,
        top: CommonConstant.SmallContainerTBPadding,
        bottom: CommonConstant.SmallContainerTBPadding
      })
      .position({
        right: CommonConstant.PageLRPadding,
        bottom: CommonConstant.NormalContainerTBPadding + CommonConstant.RadiusUltraLarge
      })
    }
    .width(CommonConstant.FullPercent)
    .height(this.swiperHeight)
  }
}