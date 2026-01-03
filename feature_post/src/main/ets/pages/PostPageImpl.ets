import { CommonConstant, VMManager } from 'base_common'
import { CustomNavTitle } from 'base_ui'
import { ImagePicker } from '../components/ImagePicker'
import { RichTextToolBar } from '../components/RichTextToolBar'
import { PostPageVM } from '../viewmodels/PostPageVM'

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
            direction: this.vm.isTabletView ? FlexDirection.Row : FlexDirection.Column
          }) {
            RichTextToolBar({ vm: this.vm })

            Column() {
              ImagePicker({ vm: this.vm })
            }
            .height(CommonConstant.FullPercent)
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
  }
}