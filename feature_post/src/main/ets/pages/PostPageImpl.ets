import { CommonConstant, VMManager } from 'base_common'
import { CustomMarkdown, CustomNavTitle } from 'base_ui'
import { CategoryPicker } from '../components/CategoryPicker'
import { ImagePicker } from '../components/ImagePicker'
import { RichTextToolBar } from '../components/RichTextToolBar'
import { PostPageVM } from '../viewmodels/PostPageVM'

const TAG = '[PostPageImpl]: ';

@ComponentV2
export struct PostPageImpl {
  @Local vm: PostPageVM = VMManager.get(PostPageVM, () => new PostPageVM())

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Column() {
          CustomNavTitle({
            vm: this.vm,
            title: $r('app.string.PostPage_title'),
            buttons: this.vm.titleButtons
          })

          Flex({
            direction: this.vm.isTabletView ? FlexDirection.Row : FlexDirection.ColumnReverse
          }) {
            RichTextToolBar({ vm: this.vm, buttons: this.vm.richTextButtons })

            Column({ space: CommonConstant.LargeContainerInnerPadding }) {
              ImagePicker({ vm: this.vm })

              CategoryPicker({ vm: this.vm })

              Column() {
                TextInput({ placeholder: $r('app.string.PostPage_post_title'), text: this.vm.postTitle, })
                  .fontSize(CommonConstant.TextSizeLarge)
                  .fontWeight(FontWeight.Bold)
                  .placeholderFont({ weight: FontWeight.Bold, size: CommonConstant.TextSizeLarge })
                  .caretColor(CommonConstant.ThemeColor)
                  .backgroundColor(Color.Transparent)
                  .width(CommonConstant.FullPercent)
                  .padding({
                    left: 0,
                    right: 0
                  })

                Divider()
                  .width(CommonConstant.FullPercent)
                  .height(CommonConstant.BorderSizeHuge)
                  .color($r('sys.color.font_tertiary'))
              }

              TextArea({ placeholder: $r('app.string.PostPage_content_placeholder'), text: this.vm.markdownContent })
                .placeholderFont({
                  size: CommonConstant.TextSizeNormal
                })
                .padding({ bottom: this.vm.window.windowBottomPadding })
                .width(CommonConstant.FullPercent)
                .fontSize(CommonConstant.TextSizeNormal)
                .borderRadius(0)
                .backgroundColor(Color.Transparent)
                .padding(0)
                .layoutWeight(1)
                .onChange((text: string) => {
                  this.vm.markdownContent = text;
                })
            }
            .padding({ left: CommonConstant.PageLRPadding, right: CommonConstant.PageLRPadding })
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            if (this.vm.isTabletView) {
              CustomMarkdown({
                content: this.vm.markdownContent,
                controller: this.vm.markdownController
              })
                .height(CommonConstant.FullPercent)
                .width(340)
                .borderRadius(CommonConstant.RadiusLarge)
                .margin({ right: CommonConstant.PageLRPadding, bottom: this.vm.window.windowBottomPadding })
                .backgroundColor($r('app.color.second_window_background'))
            }
          }
          .width(CommonConstant.FullPercent)
          .layoutWeight(1)
        }
        .width(CommonConstant.FullPercent)
        .height(CommonConstant.FullPercent)
      }
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.start_window_background'))
    .onReady(async () => {
      await this.vm.startPostPage();
    })
  }
}