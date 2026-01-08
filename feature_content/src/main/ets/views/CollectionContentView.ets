import { CommonConstant } from 'base_common';
import { CollectionContentPageVM } from '../viewmodels/CollectionContentPageVM';

@ComponentV2
export struct CollectionContentView {
  @Param @Require vm: CollectionContentPageVM;

  build() {
    Refresh({ refreshing: $$this.vm.isCollectionRefreshing }) {
      Text("test")
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
    .backgroundColor($r('app.color.start_window_background'))
  }
}