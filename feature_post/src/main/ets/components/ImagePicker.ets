import { CommonConstant } from 'base_common';
import { PostPageVM } from '../viewmodels/PostPageVM';

@ComponentV2
export struct ImagePicker {
  @Param @Require vm: PostPageVM;
  readonly NORMAL_SIZE: number = 80;
  readonly SHRINK_SIZE: number = 40;

  @Computed
  get isShrink(): boolean {
    return false;
  }

  @Computed
  get currentImageSize(): number {
    return this.isShrink ? this.SHRINK_SIZE : this.NORMAL_SIZE;
  }

  build() {
    Column() {
      List({ space: CommonConstant.NormalContainerInnerPadding }) {
        ForEach(this.vm.uploadedImages, (img: string, index: number) => {
          ListItem() {
            Stack({ alignContent: Alignment.TopEnd }) {
              Image(img)
                .objectFit(ImageFit.Cover)
                .animation({
                  curve: CommonConstant.AnimationCurveSpring,
                  duration: CommonConstant.AnimationDurationNormal
                })
                .width(this.currentImageSize)
                .height(this.currentImageSize)
                .borderRadius(CommonConstant.RadiusLarge)
                .border({ width: CommonConstant.BorderSizeLarge, color: $r('app.color.glass_border') })

              Button({ type: ButtonType.Circle }) {
                SymbolGlyph($r('sys.symbol.xmark'))
                  .fontSize(this.isShrink ? CommonConstant.TextSizeUltraTiny : CommonConstant.TextSizeSmall)
                  .fontColor([$r('sys.color.font_on_primary')])
                  .animation({ duration: CommonConstant.AnimationDurationNormal })
              }
              .width(this.isShrink ? CommonConstant.IconSizeTiny : CommonConstant.IconSizeNormal)
              .height(this.isShrink ? CommonConstant.IconSizeTiny : CommonConstant.IconSizeNormal)
              .backgroundColor(Color.Transparent)
              .backgroundBlurStyle(BlurStyle.BACKGROUND_THICK)
              .margin(CommonConstant.SmallContainerInnerPadding)
              .onClick(() => {
              })
              .animation({
                curve: CommonConstant.AnimationCurveNormal,
                duration: CommonConstant.AnimationDurationNormal
              })
            }
          }
        }, (img: string, index: number) => index.toString())

        if (this.vm.uploadedImages.length < 9) {
          ListItem() {
            Stack({ alignContent: Alignment.Center }) {
              Column({ space: this.isShrink ? 0 : CommonConstant.SmallContainerInnerPadding }) {
                SymbolGlyph($r('sys.symbol.plus'))
                  .fontSize(CommonConstant.IconSizeNormal)
                  .fontColor([$r('sys.color.font_secondary')])
                  .animation({
                    curve: CommonConstant.AnimationCurveNormal,
                    duration: CommonConstant.AnimationDurationNormal
                  })

                if (!this.isShrink) {
                  Text($r('app.string.PostPage_add_image'))
                    .fontSize(CommonConstant.TextSizeTiny)
                    .fontColor($r('sys.color.font_secondary'))
                    .transition(TransitionEffect.OPACITY.animation({
                      duration: CommonConstant.AnimationDurationNormal
                    }))
                }
              }
              .justifyContent(FlexAlign.Center)
              .width(CommonConstant.FullPercent)
              .height(CommonConstant.FullPercent)
            }
            .width(this.currentImageSize)
            .height(this.currentImageSize)
            .backgroundColor($r('app.color.second_window_background'))
            .borderRadius(CommonConstant.RadiusLarge)
            .clip(true)
            .onClick(() => {

            })
            .animation({
              curve: CommonConstant.AnimationCurveSpring,
              duration: CommonConstant.AnimationDurationNormal
            })
            .border({
              width: CommonConstant.BorderSizeLarge,
              color: $r('sys.color.font_secondary'),
              style: BorderStyle.Dashed
            })
          }
        }
      }
      .listDirection(Axis.Horizontal)
      .width(CommonConstant.FullPercent)
    }
    .width(CommonConstant.FullPercent)
  }
}