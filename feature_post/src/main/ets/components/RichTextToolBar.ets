import { CommonConstant } from 'base_common';
import { PostPageVM } from '../viewmodels/PostPageVM';

@ComponentV2
export struct RichTextToolBar {
  @Param @Require vm: PostPageVM;

  build() {
    Flex({
      direction: this.vm.isTabletView ? FlexDirection.Column : FlexDirection.Row,
    }) {
      Button("test")
    }
    .width(this.vm.isTabletView ? "auto" : CommonConstant.FullPercent)
    .height(this.vm.isTabletView ? CommonConstant.FullPercent : "auto")
  }
}