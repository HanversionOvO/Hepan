import { CommonConstant } from 'base_common';
import { FansPageVM } from '../viewmodels/FansPageVM';
import { FansPageContentView } from '../views/FansPageContentView';
import { FansPageActionsView } from '../views/FansPageActionsView';

@ComponentV2
export struct FansPage {
  @Local vm: FansPageVM = new FansPageVM();

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        FansPageContentView({ vm: this.vm })
        FansPageActionsView({ vm: this.vm })
      }
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
      .transition(CommonConstant.CONF_TRANSITION)
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.start_window_background'))
    .onReady(async (context: NavDestinationContext) => {
      const params = context.pathInfo.param as Record<string, Object>;
      if (params) {
        // 获取传递的 UID，如果没有则默认为 'me'
        if (params["uid"] !== undefined) {
          this.vm.uid = params["uid"] as number;
        } else {
          this.vm.uid = 'me';
        }

        if (params["tab"] === 'visitor') {
          this.vm.currentFansTabIndex = 1
        } else {
          this.vm.currentFansTabIndex = 0
        }
      }

      this.vm.loadData(true);
    })
  }
}
