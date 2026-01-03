import { CommonConstant, VMManager } from 'base_common'
import { CustomNavTitle } from 'base_ui'
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
            RichTextToolBar({ vm: this.vm })

            Column() {
              ImagePicker({ vm: this.vm })

              CategoryPicker({ vm: this.vm })

              TextInput({ placeholder: $r('app.string.PostPage_post_title'), text: this.vm.postTitle })
                .fontSize(CommonConstant.TextSizeUltraLarge)
                .fontWeight(FontWeight.Bold)
                .placeholderFont({ weight: FontWeight.Bold, size: CommonConstant.TextSizeUltraLarge })
                .caretColor(CommonConstant.ThemeColor)
                .backgroundColor(Color.Transparent)
                .padding({
                  left: CommonConstant.PageLRPadding,
                  right: CommonConstant.PageLRPadding,
                })
                .width(CommonConstant.FullPercent)
                .border({
                  width: CommonConstant.BorderSizeLarge,
                  style: {
                    bottom: BorderStyle.Solid
                  }
                })
            }
            .height(CommonConstant.FullPercent)
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            if (this.vm.isTabletView) {
              Column()
                .height(CommonConstant.FullPercent)
                .width(340)
                .backgroundColor($r('app.color.second_window_background'))
            }
          }
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