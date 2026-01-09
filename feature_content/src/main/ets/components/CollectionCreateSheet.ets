import { BaseVM, CommonConstant, ColorUtil } from "base_common"
import { LengthMetrics } from "@kit.ArkUI";
import { CollectionVM } from "../viewmodels/CollectionVM";

@Builder
export function collectionCreateSheetBuilder(vm: CollectionVM) {
  CollectionCreateSheet({ vm: vm })
}

@ComponentV2
struct CollectionCreateSheet {
  @Param @Require vm: CollectionVM;
  @Local tags: string[] = [];
  @Local formHash: string = "";
  @Local tagInput: string = "";

  async aboutToAppear() {
    this.formHash = await this.vm.getCreateHash();
  }

  @Builder
  tagBuilder(tag: string, index: number) {
    Row({ space: CommonConstant.SmallContainerInnerPadding }) {
      Text(tag)
        .fontSize(CommonConstant.TextSizeSmall)
        .fontColor(CommonConstant.ThemeColor)

      SymbolGlyph($r('sys.symbol.xmark'))
        .fontSize(CommonConstant.TextSizeSmall)
        .fontColor([CommonConstant.ThemeColor])
        .onClick(() => {
          this.tags.splice(index, 1);
        })
    }
    .borderRadius(CommonConstant.RadiusTiny)
    .border({ width: CommonConstant.BorderSizeNormal, color: CommonConstant.ThemeColor })
    .padding(CommonConstant.SmallContainerInnerPadding)
    .margin({ right: CommonConstant.SmallContainerInnerPadding, bottom: CommonConstant.SmallContainerInnerPadding })
  }


  addTag() {
    if (this.tagInput.trim().length > 0) {
      this.tags.push(this.tagInput.trim());
      this.tagInput = "";
    }
  }

  build() {
    Column({ space: CommonConstant.LargeContainerInnerPadding }) {

      TextInput({ placeholder: $r('app.string.CollectionPage_collection_title') })
        .borderRadius(CommonConstant.RadiusSmall)
        .backgroundColor($r('app.color.second_window_background'))
        .caretColor(CommonConstant.ThemeColor)


     TextArea({ placeholder: $r('app.string.CollectionPage_collection_desc') })
        .borderRadius(CommonConstant.RadiusSmall)
        .height(CommonConstant.TextInputSizeNormal)
        .backgroundColor($r('app.color.second_window_background'))
        .caretColor(CommonConstant.ThemeColor)



        Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Center, space: {
          cross: LengthMetrics.vp(CommonConstant.SmallContainerTBPadding)
        } }) {
          TextInput({ text: this.tagInput, placeholder: $r('app.string.CollectionPage_collection_tags') })
            .onChange((value) => {
              this.tagInput = value;
            })
            .onSubmit(() => {
              this.addTag(); 
            })
            .fontSize(CommonConstant.TextSizeNormal)
            .backgroundColor(Color.Transparent)
            .caretColor(CommonConstant.ThemeColor)
            .layoutWeight(1)
            .padding(0)

          ForEach(this.tags, (tag: string, index: number) => {
            this.tagBuilder(tag, index)
          })
        }
      .width(CommonConstant.FullPercent)
      .backgroundColor($r('app.color.second_window_background'))
      .borderRadius(CommonConstant.RadiusSmall)
      .padding({
        left: CommonConstant.SmallContainerLRPadding,
        right: CommonConstant.SmallContainerLRPadding,
        bottom: CommonConstant.SmallContainerTBPadding,
        top:CommonConstant.SmallContainerTBPadding
      })

      Button($r('app.string.CollectionPage_create_collection'))
      .width(CommonConstant.FullPercent)
      .borderRadius(CommonConstant.RadiusSmall)
      .fontColor($r('sys.color.font_on_primary'))
      .backgroundColor(CommonConstant.ThemeColor)
    }
    .width(CommonConstant.FullPercent)
    .padding({
      left: CommonConstant.NormalContainerLRPadding,
      right: CommonConstant.NormalContainerLRPadding,
      bottom: this.vm.window.windowBottomPadding + CommonConstant.NormalContainerTBPadding
    })
  }
}