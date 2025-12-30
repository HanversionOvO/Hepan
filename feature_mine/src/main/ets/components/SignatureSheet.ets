import { MinePageVM } from "../viewmodels/MinePageVM";
import { CommonConstant } from 'base_common';

@Builder
export function signatureSheetBuilder(vm: MinePageVM) {
  SignatureSheet({vm})
}

@ComponentV2
struct SignatureSheet {
  @Param @Require vm: MinePageVM
  @Local signature: ResourceStr = "";
  
  build() {
        Column({ space: CommonConstant.LargeContainerInnerPadding }) {
      TextArea({ placeholder: this.vm.user?.signature || $r('app.string.MinePage_signature_placeHolder'), text:$$this.signature })
        .height(CommonConstant.TextInputSizeNormal)
        .width(CommonConstant.FullPercent)
        .borderRadius(CommonConstant.RadiusNormal)

      Button($r('app.string.MinePage_edit_sig'))
        .width(CommonConstant.FullPercent)
        .borderRadius(CommonConstant.RadiusNormal)
        .fontSize(CommonConstant.TextSizeNormal)
        .backgroundColor(CommonConstant.ThemeColor)
        .fontColor($r('sys.color.font_on_primary'))
        .onClick(async () => {
          await this.vm.editSignature(this.signature)
        })
    }
    .padding({
      left: CommonConstant.PageLRPadding,
      right: CommonConstant.PageLRPadding,
      bottom: CommonConstant.PageLRPadding + this.vm.window.windowBottomPadding
    })
  }
}