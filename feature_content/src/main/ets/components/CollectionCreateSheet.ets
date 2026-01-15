import { ColorUtil, CommonConstant, ToastUtil } from 'base_common';
import { LengthMetrics } from '@kit.ArkUI';
import { CollectionVM } from '../viewmodels/CollectionVM';

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
  @Local title: string = "";
  @Local desc: string = "";

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
    .borderRadius(CommonConstant.RadiusRound)
    .backgroundColor(ColorUtil.opacity(CommonConstant.ThemeColor))
    .border({ width: CommonConstant.BorderSizeNormal, color: CommonConstant.ThemeColor })
    .padding({
      left: CommonConstant.SmallContainerLRPadding / 2,
      right: CommonConstant.SmallContainerLRPadding / 2,
      top: CommonConstant.SmallContainerTBPadding / 2,
      bottom: CommonConstant.SmallContainerTBPadding / 2
    })
  }

  addTag() {
    if (this.tagInput.trim().length > 0) {
      this.tags.push(this.tagInput.trim());
      this.tagInput = "";
    }
  }

  build() {
    Column({ space: CommonConstant.LargeContainerInnerPadding }) {
      Column() {
        Row({ space: CommonConstant.NormalContainerInnerPadding }) {
          SymbolGlyph($r('sys.symbol.pencil_and_card'))
            .fontSize(CommonConstant.TextSizeLarge)
            .fontColor([CommonConstant.ThemeColor])

          TextInput({ placeholder: $r('app.string.CollectionPage_collection_title') })
            .placeholderFont({ size: CommonConstant.TextSizeLarge, weight: FontWeight.Bold })
            .fontWeight(FontWeight.Bold)
            .fontSize(CommonConstant.TextSizeLarge)
            .caretColor(CommonConstant.ThemeColor)
            .backgroundColor(Color.Transparent)
            .padding(0)
            .layoutWeight(1)
            .onChange((value: string) => {
              this.title = value;
            })
        }
        .padding({
          left: CommonConstant.NormalContainerLRPadding,
          right: CommonConstant.NormalContainerLRPadding,
          top: CommonConstant.NormalContainerTBPadding,
          bottom: CommonConstant.NormalContainerTBPadding
        })
        .backgroundColor($r('app.color.glass_background'))
        .borderRadius({
          topLeft: CommonConstant.RadiusLarge,
          topRight: CommonConstant.RadiusLarge
        })


        TextArea({ placeholder: $r('app.string.CollectionPage_collection_desc') })
          .borderRadius({
            bottomLeft: CommonConstant.RadiusLarge,
            bottomRight: CommonConstant.RadiusLarge
          })
          .placeholderFont({ size: CommonConstant.TextSizeNormal })
          .height(CommonConstant.TextInputSizeNormal)
          .padding({
            left: CommonConstant.NormalContainerLRPadding,
            right: CommonConstant.NormalContainerLRPadding,
            top: CommonConstant.NormalContainerTBPadding,
            bottom: CommonConstant.NormalContainerTBPadding
          })
          .caretColor(CommonConstant.ThemeColor)
          .backgroundColor($r('app.color.glass_background'))
          .onChange((value: string) => {
            this.desc = value;
          })
      }

      Column({ space: CommonConstant.SmallContainerTBPadding }) {
        Row({ space: CommonConstant.SmallContainerInnerPadding }) {
          SymbolGlyph($r('sys.symbol.label'))
            .fontSize(CommonConstant.TextSizeNormal)
            .fontWeight(FontWeight.Medium)
            .fontColor([CommonConstant.ThemeColor])

          Text($r('app.string.CollectionPage_collection_tags'))
            .fontSize(CommonConstant.TextSizeNormal)
            .fontWeight(FontWeight.Medium)
        }
        .width(CommonConstant.FullPercent)
        .justifyContent(FlexAlign.Start)

        Flex({
          wrap: FlexWrap.Wrap, alignItems: ItemAlign.Start, space: {
            main: LengthMetrics.vp(CommonConstant.SmallContainerTBPadding),
            cross: LengthMetrics.vp(CommonConstant.SmallContainerTBPadding)
          }
        }) {
          ForEach(this.tags, (tag: string, index: number) => {
            this.tagBuilder(tag, index)
          })

          TextInput({ text: this.tagInput, placeholder: $r('app.string.CollectionPage_collection_tags_desc') })
            .onChange((value) => {
              this.tagInput = value;
            })
            .onSubmit(() => {
              this.addTag();
            })
            .placeholderFont({ size: CommonConstant.TextSizeSmall })
            .fontSize(CommonConstant.TextSizeSmall)
            .backgroundColor($r('app.color.glass_background'))
            .caretColor(CommonConstant.ThemeColor)
            .flexGrow(1)
            .width(0)
            .padding({
              top: 0,
              bottom: 0,
            })
        }
      }
      .width(CommonConstant.FullPercent)

      Button($r('app.string.CollectionPage_create_collection'))
        .width(CommonConstant.FullPercent)
        .fontSize(CommonConstant.TextSizeNormal)
        .borderRadius(CommonConstant.RadiusSmall)
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor(CommonConstant.ThemeColor)
        .onClick(async () => {
          if (this.title === "") {
            ToastUtil.showLightWarn($r('app.string.CollectionPage_collection_input_title'))
            return;
          }

          await this.vm.createCollection(this.title, this.formHash, this.desc, this.tags);
        })
    }
    .width(CommonConstant.FullPercent)
    .padding({
      left: CommonConstant.NormalContainerLRPadding,
      right: CommonConstant.NormalContainerLRPadding,
      bottom: this.vm.window.windowBottomPadding + CommonConstant.NormalContainerTBPadding
    })
  }
}